#cython: language_level=3

from libc.string cimport memset, memcpy


cdef cppclass optional[T]:
    bint m_has_value
    T m_value

    optional():
        memset(this, 0, sizeof(optional[T]))

    bint has_value():
        return this.m_has_value

    T value():
        return this.m_value

    void set(T v):
        this.m_value = v
        this.m_has_value = True

    void reset():
        this.m_has_value = False
