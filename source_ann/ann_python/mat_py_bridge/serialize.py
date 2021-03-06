# (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

import numpy as np
import struct


def get(data):
    """Serialize a Python dict to be transferred to MATLAB.

    This function can only serialize very specific Python data:
        - string
        - array:
            - multi-dimensional arrays are supported
            - float64, float32, bool, int8, uint8, int32, uint32, int64, uint64
        - dictionary:
            - the values of the dictionary can be strings or array
            - the values of the dictionary can be other structs
            - all dictionary keys have to be strings

    The reasons of these limitation are:
        - To keep this function as simple as possible
        - The mismatch between the Python data types and the MATLAB data types

    Warning: The serialization/deserialization routine have meant to be safe against malicious data.

    Parameters:
    data (dict): Data to be seserialized

    Returns:
    bytes: Serialized data

   """

    # init array
    bytes_array = bytearray()

    # serialize data
    bytes_array = serialize_data(bytes_array, data)

    return bytes_array


def serialize_data(bytes_array, data):
    """Serialize a Python data.

    Parameters:
    bytes_array (bytes): Bytes array to add the new data
    data (str/array): Data to be serialized

    Returns:
    bytes: Serialized data

   """

    # encode the data type: string or numpy array
    bytes_add = class_encode(data)
    bytes_array = append_byte(bytes_array, bytes_add)

    # encode the data
    if isinstance(data, str):
        bytes_array = serialize_char(bytes_array, data)
    elif isinstance(data, dict):
        bytes_array = serialize_struct(bytes_array, data)
    else:
        bytes_array = serialize_matrix(bytes_array, data)

    return bytes_array


def serialize_struct(bytes_array, data):
    """Serialize a Python dict.

    Parameters:
    bytes_array (bytes): Bytes array to add the new data
    data (dict): Data to be serialized

    Returns:
    bytes: Serialized data

   """

    # encode the number of fields
    bytes_add = len(data)
    bytes_add = struct.pack('I', bytes_add)
    bytes_array = append_byte(bytes_array, bytes_add)

    # serialize the keys and values
    for field in data:
        assert isinstance(field, str), 'invalid dict key type'
        bytes_array = serialize_data(bytes_array, field)
        bytes_array = serialize_data(bytes_array, data[field])

    return bytes_array


def serialize_char(bytes_array, data):
    """Serialize a Python string.

    Parameters:
    bytes_array (bytes): Bytes array to add the new data
    data (str): Data to be serialized

    Returns:
    bytes: Bytes array with the new serialized data

   """
    
    # encode the length
    n_length = len(data)
    bytes_add = struct.pack('I', n_length)
    bytes_array = append_byte(bytes_array, bytes_add)

    # encode the data
    bytes_add = bytearray(data, 'utf-8')
    bytes_array = append_byte(bytes_array, bytes_add)

    return bytes_array


def serialize_matrix(bytes_array, data):
    """Serialize a numpy array.

    Parameters:
    bytes_array (bytes): Bytes array to add the new data
    data (array): Data to be serialized

    Returns:
    bytes: Bytes array with the new serialized data

   """

    # get the shape of the array (size along dimensions)
    size_vec = data.shape

    # encode the number of dimensions
    bytes_add = struct.pack('I', len(size_vec))
    bytes_array = append_byte(bytes_array, bytes_add)

    # encode the number of element per dimension
    bytes_add = struct.pack('%sI' % len(size_vec), *size_vec)
    bytes_array = append_byte(bytes_array, bytes_add)

    # encode the data: warning MATLAB is using FORTRAN byte order, not the C one
    bytes_add = data.tobytes(order='F')
    bytes_array = append_byte(bytes_array, bytes_add)

    return bytes_array


def class_encode(data):
    """Encode the data type with a byte.

    Parameters:
    data (various): Data to be encoded

    Returns:
    byte: Byte with the encoded type

   """

    if isinstance(data, dict):
        b = b'\x0c'
    elif isinstance(data, str):
            b = b'\x03'
    elif isinstance(data, np.ndarray):
        if data.dtype=='float64':
            b = b'\x00'
        elif data.dtype=='float32':
            b = b'\x01'
        elif data.dtype=='bool':
            b = b'\x02'
        elif data.dtype=='int8':
            b = b'\x04'
        elif data.dtype=='uint8':
            b = b'\x05'
        elif data.dtype=='int32':
            b = b'\x08'
        elif data.dtype=='uint32':
            b = b'\x09'
        elif data.dtype=='int64':
            b = b'\x0a'
        elif data.dtype=='uint64':
            b = b'\x0b'
        else:
            raise TypeError('invalid numpy data type')
    else:
        raise TypeError('invalid data type')

    return b


def append_byte(bytes_array, bytes_add):
    """Append bytes to a byte array.

    Parameters:
    bytes_array (bytes): Byte array
    bytes_add (bytes): Bytes to be added

    Returns:
    bytes: Resulting byte array

   """

    bytes_array += bytes_add

    return bytes_array