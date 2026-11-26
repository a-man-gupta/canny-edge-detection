// Private seed/queue, narrow-slab, and benchmark implementations.
#define INLINE static inline __attribute__((always_inline))

INLINE __m256i load(const uint8_t *p) { return _mm256_loadu_si256((const __m256i *)p); }
// a | b | c in one vpternlogd.
INLINE __m256i or3(__m256i a, __m256i b, __m256i c) {
  return _mm256_ternarylogic_epi32(a, b, c, 0xFE);
}
// a | (b & c) in one vpternlogd.
INLINE __m256i or_and(__m256i a, __m256i b, __m256i c) { // Port 3
  return _mm256_ternarylogic_epi32(a, b, c, 0xF8);
}

template <int R>
INLINE long rows_repeat(const uint8_t *labels, uint8_t *edges, long stride, long begin, long n,
                        uint32_t *hits, long reps) {
  const __m256i two = _mm256_set1_epi8(2);
  long count = 0;
  for (long pass = 0; pass < reps; ++pass) {
    count = 0;
    for (long x = begin; x < begin + n; x += 32) {
      const uint8_t *p = labels + x;
      __m256i center[R + 2], h[R + 2];
      for (int r = 0; r < R + 2; ++r) {
        const uint8_t *row = p + (r - 1) * stride;
        center[r] = load(row);
        h[r] = or3(load(row - 1), center[r], load(row + 1));
      }
      __m256i seeds;
      for (int r = 1; r <= R; ++r) {
        __m256i all = or3(h[r - 1], h[r], h[r + 1]);
        _mm256_storeu_si256((__m256i *)(edges + (r - 1) * stride + x),
                            _mm256_cmpeq_epi8(center[r], two));
        __m256i doubled = _mm256_add_epi8(center[r], center[r]);
        seeds = r == 1 ? _mm256_and_si256(doubled, all) : or_and(seeds, doubled, all);
      }
      if (__builtin_expect(!_mm256_testz_si256(seeds, seeds), 0))
        hits[count++] = uint32_t(x);
    }
    // Compiler barrier only: every pass executes; no fence instruction.
    std::atomic_signal_fence(std::memory_order_seq_cst);
  }
  return count;
}

extern "C" __attribute__((noinline)) long
hysteresis_rows4_repeat(const uint8_t *labels, uint8_t *edges, long stride, long begin, long n,
                        uint32_t *hits, long reps) {
  return rows_repeat<4>(labels, edges, stride, begin, n, hits, reps);
}

extern "C" __attribute__((noinline)) long
hysteresis_rows1_repeat(const uint8_t *labels, uint8_t *edges, long stride, long begin, long n,
                        uint32_t *hits, long reps) {
  return rows_repeat<1>(labels, edges, stride, begin, n, hits, reps);
}

// Emit exact seed lanes while their neighborhood is still in vector registers.
static void seed_mask_row(const uint8_t *p, uint8_t *edge, int stride, int width,
                          size_t base, std::vector<size_t> &queue) {
  const __m256i one = _mm256_set1_epi8(1), two = _mm256_set1_epi8(2);
  for (int x = 1; x <= width; x += 32) {
    const uint8_t *c = p + x;
    auto horizontal = [](const uint8_t *r) { return or3(load(r-1),load(r),load(r+1)); };
    __m256i center = load(c);
    __m256i neighbors = or3(horizontal(c-stride),horizontal(c),horizontal(c+stride));
    __m256i weak = _mm256_cmpeq_epi8(center,one);
    __m256i strong_neighbor = _mm256_cmpeq_epi8(_mm256_and_si256(neighbors,two),two);
    __m256i seed = _mm256_and_si256(weak,strong_neighbor);
    _mm256_storeu_si256((__m256i*)(edge+x),_mm256_or_si256(seed,_mm256_cmpeq_epi8(center,two)));
    unsigned mask = unsigned(_mm256_movemask_epi8(seed));
    while (mask) {
      queue.push_back(base+x+__builtin_ctz(mask));
      mask &= mask-1;
    }
  }
}

template<bool exact_masks, bool zero_side_borders=false>
static void track(int w, int h, const uint8_t *labels, uint8_t *edges,
                       std::vector<size_t> &queue) {
  queue.clear();
  if (w <= 0 || h <= 0)
    return;
  // A weak pixel with a strong neighbor starts the queue, already marked as an edge.
  auto seed = [&](int y, int x) {
    for (int j = -1; j <= 1; ++j)
      for (int k = -1; k <= 1; ++k) {
        if (y + j < 0 || y + j >= h || x + k < 0 || x + k >= w)
          continue;
        if (labels[size_t(y + j) * w + x + k] == 2) {
          edges[size_t(y) * w + x] = 255;
          queue.push_back(size_t(y) * w + x);
          return;
        }
      }
  };
  auto scalar_pixel = [&](int y, int x) {
    const size_t i = size_t(y) * w + x;
    edges[i] = labels[i] == 2 ? 255 : 0;
    if (labels[i] == 1)
      seed(y, x);
  };

  // Columns 1 .. vector_pixels go through the vector pass on rows 1 .. h-2.
  const int vector_pixels = h >= 3 && w >= 34 ? (w - 2) / 32 * 32 : 0;
  std::vector<uint32_t> hits(vector_pixels / 32 + 1);
  auto rows = [&](int y, int count) {
    const size_t row = size_t(y) * w;
    long found = 0;
    if constexpr (exact_masks) {
      for (int r=0; r<count; ++r) {
        size_t offset=row+size_t(r)*w;
        seed_mask_row(labels+offset,edges+offset,w,vector_pixels,offset,queue);
      }
    } else if (vector_pixels)
      found = count == 4 ? hysteresis_rows4_repeat(labels + row, edges + row, w, 1, vector_pixels,
                                                   hits.data(), 1)
                         : hysteresis_rows1_repeat(labels + row, edges + row, w, 1, vector_pixels,
                                                   hits.data(), 1);
    for (long f = 0; f < found; ++f)
      for (int r = 0; r < count; ++r)
        for (int x = int(hits[f]); x < int(hits[f]) + 32; ++x)
          if (labels[size_t(y + r) * w + x] == 1)
            seed(y + r, x);
    for (int r = 0; r < count; ++r) {
      scalar_pixel(y + r, 0);
      for (int x = 1 + vector_pixels; x < w; ++x)
        scalar_pixel(y + r, x);
    }
  };

  for (int x = 0; x < w; ++x)
    scalar_pixel(0, x);
  int y = 1;
  for (; y + 4 <= h - 1; y += 4)
    rows(y, 4);
  for (; y < h - 1; ++y)
    rows(y, 1);
  if (h > 1)
    for (int x = 0; x < w; ++x)
      scalar_pixel(h - 1, x);

  // Queue pass: grow from the seeds through weak pixels.
  for (size_t head = 0; head < queue.size(); ++head) {
    const size_t i = queue[head];
    if constexpr (zero_side_borders) {
      // NMS clears both outer columns. Queued pixels therefore have valid left/right neighbors.
      auto visit = [&](size_t neighbor) {
        if (labels[neighbor]==1 && edges[neighbor]==0) {
          edges[neighbor]=255;
          queue.push_back(neighbor);
        }
      };
      auto visit_row = [&](size_t center) { visit(center-1); visit(center); visit(center+1); };
      if (i>=size_t(w)) visit_row(i-w);
      visit(i-1);
      visit(i+1);
      if (i<size_t(h-1)*w) visit_row(i+w);
      continue;
    }
    const int y = int(i / w), x = int(i % w);
    for (int j = -1; j <= 1; ++j)
      for (int k = -1; k <= 1; ++k) {
        if (y + j < 0 || y + j >= h || x + k < 0 || x + k >= w)
          continue;
        const size_t nb = size_t(y + j) * w + x + k;
        if (labels[nb] == 1 && !edges[nb]) {
          edges[nb] = 255;
          queue.push_back(nb);
        }
      }
  }
}

void hysteresis_kernel(int w,int h,const uint8_t *labels,uint8_t *edges,std::vector<size_t> &queue) {
  track<false, false>(w,h,labels,edges,queue);
}

void hysteresis_mask_kernel(int w,int h,const uint8_t *labels,uint8_t *edges,std::vector<size_t> &queue) {
  track<true, false>(w,h,labels,edges,queue);
}

// Crossing between the last and first lane is harmless because slab side
// columns are zero.
static inline __m256i horizontal_reach(__m256i row) {
  auto left_carry = _mm256_srli_epi64(_mm256_permute4x64_epi64(row, 0x93), 63);
  auto right_carry = _mm256_slli_epi64(_mm256_permute4x64_epi64(row, 0x39), 63);
  auto same = or3(row, _mm256_add_epi64(row, row), _mm256_srli_epi64(row, 1));
  return or3(same, left_carry, right_carry);
}
// A 512-bit vector holds two 256-pixel rows. Each half wraps only within its
// own row.
static inline __m512i horizontal_pair(__m512i row) {
  auto lc = _mm512_srli_epi64(_mm512_permutex_epi64(row, 0x93), 63);
  auto rc = _mm512_slli_epi64(_mm512_permutex_epi64(row, 0x39), 63);
  auto same = _mm512_ternarylogic_epi64(row, _mm512_add_epi64(row, row),
                                        _mm512_srli_epi64(row, 1), 0xfe);
  return _mm512_ternarylogic_epi64(same, lc, rc, 0xfe);
}
template<int fixed_height=0> static bool sweep_pair(int height, uint64_t *reached, const uint64_t *weak) {
  const int h = fixed_height ? fixed_height : height;
  for (int pass = 0; pass < 32; ++pass) {
    auto changes = _mm512_setzero_si512(), above = changes;
    auto row = _mm512_loadu_si512(reached), middle = horizontal_pair(row);
    for (int r = 0; r < h; r += 2) {
      size_t i = size_t(r) * 4;
      auto next = r + 2 < h ? _mm512_loadu_si512(reached + i + 8)
                            : _mm512_setzero_si512();
      auto below = horizontal_pair(next);
      // Share both horizontal masks and borrow one row from each neighboring
      // pair.
      auto other = _mm512_shuffle_i64x2(middle, middle, 0x4e);
      auto border = _mm512_shuffle_i64x2(above, below, 0x4e);
      auto nearby = _mm512_ternarylogic_epi64(middle, other, border, 0xfe);
      auto result = _mm512_ternarylogic_epi64(row, _mm512_loadu_si512(weak + i),
                                              nearby, 0xf8);
      changes = _mm512_ternarylogic_epi64(changes, result, row, 0xf6);
      _mm512_storeu_si512(reached + i, result);
      above = middle;
      middle = below;
      row = next;
    }
    if (!_mm512_test_epi64_mask(changes, changes))
      return true;
  }
  return false;
}

static bool sweep256(int h, int pitch, uint64_t *reached,
                     const uint64_t *weak) {
  // Cache the old horizontal reach so one sweep advances every path by one
  // pixel.
  for (int pass = 0; pass < 32; ++pass) {
    __m256i changes = _mm256_setzero_si256();
    __m256i above = _mm256_setzero_si256();
    __m256i row = _mm256_loadu_si256((const __m256i *)reached);
    __m256i middle = horizontal_reach(row);
    for (int r = 0; r < h; ++r) {
      size_t i = size_t(r) * pitch;
      auto next = _mm256_loadu_si256((const __m256i *)(reached + i + pitch));
      auto below = horizontal_reach(next);
      auto nearby = or3(above, middle, below);
      auto allowed = _mm256_loadu_si256((const __m256i *)(weak + i));
      auto result = or_and(row, allowed, nearby);
      changes = _mm256_ternarylogic_epi64(changes, result, row, 0xF6);
      _mm256_storeu_si256((__m256i *)(reached + i), result);
      above = middle;
      middle = below;
      row = next;
    }
    if (_mm256_testz_si256(changes, changes))
      return true;
  }
  return false;
}
// Four adjacent 64-pixel masks form one row. Both mask planes have a zero halo
// row.
__attribute__((noinline,target("avx512bw,avx512vl"))) static void
pack_labels(size_t count,const uint8_t* labels,uint64_t* reached,uint64_t* weak){
  const auto one = _mm512_set1_epi8(1), two = _mm512_set1_epi8(2);
#pragma GCC unroll 4
  for (size_t i = 0; i < count; ++i) {
    auto pixels = _mm512_loadu_si512(labels + 64 * i);
    reached[i] = _mm512_cmpeq_epi8_mask(pixels, two);
    weak[i] = _mm512_cmpeq_epi8_mask(pixels, one);
  }
}
__attribute__((noinline,target("avx512bw,avx512vl"))) static void
store_edges(size_t count,const uint64_t* reached,uint8_t* out){
#pragma GCC unroll 4
  for (size_t i = 0; i < count; ++i)
    _mm512_storeu_si512(out + 64 * i, _mm512_maskz_set1_epi8(reached[i], -1));
}
__attribute__((target("avx512bw,avx512vl"))) static bool
track256(int h, const uint8_t *labels, uint8_t *out,
         std::vector<size_t> &scratch) {
  const size_t count=size_t(h)*4, plane=(count+15)&~size_t(7);
  alignas(64) uint64_t small[2*(32*4+8)+16];
  uint64_t* reached;
  if (h<=32) reached=small+8;
  else {
    scratch.resize(2*plane+16);
    reached=(uint64_t*)((uintptr_t(scratch.data()+8)+63)&~uintptr_t(63));
  }
  auto* weak=reached+plane;
  _mm256_storeu_si256((__m256i *)(reached - 4), _mm256_setzero_si256());
  _mm256_storeu_si256((__m256i *)(reached + count), _mm256_setzero_si256());
  pack_labels(count,labels,reached,weak);
  if (!(h == 8 ? sweep_pair<8>(8, reached, weak) : h % 2 == 0 ? sweep_pair(h, reached, weak) : sweep256(h, 4, reached, weak)))
    return false;
  store_edges(count,reached,out);
  scratch.clear();
  return true;
}

