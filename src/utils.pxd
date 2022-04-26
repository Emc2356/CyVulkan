#cython: language_level=3

# C libraries
from CyGlfw cimport *
from CyVulkan cimport *

# libc
from libc.stdint cimport int8_t, int16_t, int32_t, int64_t, uint8_t, uint16_t, uint32_t, uint64_t
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *

# libcpp
from libcpp.vector cimport vector

# CPython
from cpython.object cimport PyObject


cdef extern from * nogil:
    """
    #include <ostream>
    #include <string.h>

    #define STRINGIFY(x) #x
    #define TOSTRING(x) STRINGIFY(x)
    #define CERROR_macro(desc, ...) printf(desc, __VA_ARGS__); printf(\"\\n\"); exit(1)
    #define STDCOUT_macro(desc) std::cout << desc << std::endl;
    #define STDCERR_macro(desc) std::cerr << desc << std::endl;
    #define AddrOfObject_macro(o) ((long long int)o)
    #define PyObject_FromObject_macro(o) o

    template<typename T>
    T PRIVATE_zero_initialize_instance_impl() {
        T temp;
        memset(&temp, 0, sizeof(T));
        return temp;
    }
    """
    void CERROR "CERROR_macro"(char * desc, ...)
    void STDCERR "STDCERR_macro"(char * desc)
    void STDCOUT "STDCOUT_macro"(char * desc)

    long long int AddrOfObject "AddrOfObject_macro"(object o)
    PyObject* PyObject_FromObject "PyObject_FromObject_macro"(object o)

    T ZeroInit "PRIVATE_zero_initialize_instance_impl"[T]()

ctypedef vector[char*] char_ptr_vector
ctypedef vector[int] int_vector

cdef inline bint streq(const char* a, const char* b):
    return strcmp(a, b) == 0
