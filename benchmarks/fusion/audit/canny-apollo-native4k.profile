# To display the perf.data header info, please use --header/--header-only options.
#
#
# Total Lost Samples: 0
#
# Samples: 1K of event 'cycles:u'
# Event count (approx.): 478000000
#
# Overhead  Symbol                                  IPC   [IPC Coverage]
# ........  ......................................  ....................
#
    43.20%  [.] hysteresis_mask_kernel              -      -            
    11.82%  [.] expand_impl                         -      -            
    11.24%  [.] nms_labels                          -      -            
     7.27%  [.] seed_mask_row                       -      -            
     6.22%  [.] sobel_kernel                        -      -            
     5.86%  [.] (anonymous namespace)::tile<false>  -      -            
     4.55%  [.] __memmove_evex_unaligned_erms       -      -            
     4.03%  [.] gaussian_horiz_row                  -      -            
     3.29%  [.] gaussian_vert_row                   -      -            
     1.36%  [.] expand_tail                         -      -            
     0.47%  [.] canny_tiled                         -      -            
     0.37%  [.] vert_tail                           -      -            
     0.10%  [.] gaussian_ring_row                   -      -            


#
# (Tip: Search options using a keyword: perf report -h <keyword>)
#
