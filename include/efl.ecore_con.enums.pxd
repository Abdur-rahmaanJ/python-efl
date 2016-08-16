cdef extern from "Ecore_Con.h":
    # enums
    ctypedef enum Ecore_Con_Type:
        ECORE_CON_LOCAL_USER
        ECORE_CON_LOCAL_SYSTEM
        ECORE_CON_LOCAL_ABSTRACT
        ECORE_CON_REMOTE_TCP
        ECORE_CON_REMOTE_MCAST
        ECORE_CON_REMOTE_UDP
        ECORE_CON_REMOTE_BROADCAST
        ECORE_CON_REMOTE_NODELAY
        ECORE_CON_REMOTE_CORK
        ECORE_CON_USE_SSL2
        ECORE_CON_USE_SSL3
        ECORE_CON_USE_TLS
        ECORE_CON_USE_MIXED
        ECORE_CON_LOAD_CERT
        ECORE_CON_NO_PROXY
        ECORE_CON_SOCKET_ACTIVATE

    ctypedef enum Ecore_Con_Url_Time:
        ECORE_CON_URL_TIME_NONE
        ECORE_CON_URL_TIME_IFMODSINCE
        ECORE_CON_URL_TIME_IFUNMODSINCE

    ctypedef enum Ecore_Con_Url_Http_Version:
        ECORE_CON_URL_HTTP_VERSION_1_0
        ECORE_CON_URL_HTTP_VERSION_1_1
