
function(fastsimd_add_feature_set_source feature_set)
    set(feature_set_source "${simd_library_source_dir}/${simd_library_name}_${feature_set}.cpp")
    set(simd_inl_full "${CMAKE_CURRENT_LIST_DIR}/${simd_inl}")
    
    configure_file("${FastSIMD_SOURCE_DIR}/cmake/feature_set_source.cpp.in" ${feature_set_source})
    target_sources(${simd_library_name} PRIVATE ${feature_set_source})
            
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        # MSVC 32bit needs SSE2 flag for all SSE levels
        if(${feature_set} MATCHES "SSE[^(0-9)]" AND CMAKE_SIZEOF_VOID_P EQUAL 4) 
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "/arch:SSE2")
        
        elseif(${feature_set} MATCHES "AVX[^(0-9)]")
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "/arch:AVX")
        
        elseif(${feature_set} MATCHES AVX2)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "/arch:AVX2")

        elseif(${feature_set} MATCHES AVX512)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "/arch:AVX512")
        endif()
    else()
        if(${feature_set} MATCHES SSE2 AND CMAKE_SIZEOF_VOID_P EQUAL 4)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-msse2")
        
        elseif(${feature_set} MATCHES SSE3)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-msse3")
        
        elseif(${feature_set} MATCHES SSSE3)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-mssse3")
        
        elseif(${feature_set} MATCHES SSE41)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-msse4.1")
        
        elseif(${feature_set} MATCHES SSE42)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-msse4.2")
        
        elseif(${feature_set} MATCHES "AVX[^(0-9)]")
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-mavx")
        
        elseif(${feature_set} MATCHES AVX2)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-mavx2 -mfma")

        elseif(${feature_set} MATCHES AVX512)
            set_source_files_properties(${feature_set_source} PROPERTIES COMPILE_FLAGS "-mavx512f -mavx512dq -mavx512vl -mavx512bw -mfma")
        endif()
    endif()
    
endfunction()

function(fastsimd_create_simd_library simd_library_name simd_inl)
    
    set(feature_sets
        SSE2
        SSE41
        AVX2
        AVX512_Baseline)

    add_library(${simd_library_name} STATIC)
    target_link_libraries(${simd_library_name} PUBLIC fastsimd)
    target_include_directories(${simd_library_name} PRIVATE "${FastSIMD_SOURCE_DIR}/src")
    
    set(simd_library_source_dir "${CMAKE_CURRENT_BINARY_DIR}/fastsimd/${simd_library_name}")
    set(feature_set_list "")

    foreach(feature_set ${feature_sets})
        list(APPEND feature_set_list "FastSIMD::FeatureSet::${feature_set}")      
        fastsimd_add_feature_set_source(${feature_set})
    endforeach()  

    # Create array of compiled feature sets for lookup in FastSIMD::New()
    string(REPLACE ";" ",\n" feature_set_list "${feature_set_list}")
    configure_file("${FastSIMD_SOURCE_DIR}/cmake/simd_lib_config.h.in" "${simd_library_source_dir}/simd_lib_config.h")

endfunction()