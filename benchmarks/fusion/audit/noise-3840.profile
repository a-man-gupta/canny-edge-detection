# To display the perf.data header info, please use --header/--header-only options.
#
#
# Total Lost Samples: 0
#
# Samples: 2K of event 'cycles:u'
# Event count (approx.): 657000000
#
# Overhead  Symbol                                  IPC   [IPC Coverage]
# ........  ......................................  ....................
#
    50.95%  [.] hysteresis_mask_kernel              -      -            
    11.26%  [.] seed_mask_row                       -      -            
     8.41%  [.] nms_labels                          -      -            
     8.37%  [.] expand_impl                         -      -            
     5.71%  [.] sobel_kernel                        -      -            
     4.41%  [.] __memmove_evex_unaligned_erms       -      -            
     4.15%  [.] (anonymous namespace)::tile<false>  -      -            
     2.97%  [.] gaussian_horiz_row                  -      -            
     2.74%  [.] gaussian_vert_row                   -      -            
     0.49%  [.] expand_tail                         -      -            
     0.15%  [.] canny_tiled                         -      -            
     0.15%  [.] vert_tail                           -      -            
     0.11%  [.] memcpy@plt                          -      -            


#
# (Tip: Show current config key-value pairs: perf config --list)
#
