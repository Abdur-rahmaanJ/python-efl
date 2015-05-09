cdef extern from "Elementary.h":

    cpdef enum Elm_Fileselector_Mode:
        ELM_FILESELECTOR_LIST
        ELM_FILESELECTOR_GRID
    ctypedef enum Elm_Fileselector_Mode:
        pass

    cpdef enum Elm_Fileselector_Sort:
        ELM_FILESELECTOR_SORT_BY_FILENAME_ASC
        ELM_FILESELECTOR_SORT_BY_FILENAME_DESC
        ELM_FILESELECTOR_SORT_BY_TYPE_ASC
        ELM_FILESELECTOR_SORT_BY_TYPE_DESC
        ELM_FILESELECTOR_SORT_BY_SIZE_ASC
        ELM_FILESELECTOR_SORT_BY_SIZE_DESC
        ELM_FILESELECTOR_SORT_BY_MODIFIED_ASC
        ELM_FILESELECTOR_SORT_BY_MODIFIED_DESC
        ELM_FILESELECTOR_SORT_LAST
    ctypedef enum Elm_Fileselector_Sort:
        pass


    ctypedef Eina_Bool (*Elm_Fileselector_Filter_Func)(const char *path, Eina_Bool dir, void *data)

    Evas_Object *           elm_fileselector_add(Evas_Object *parent)
    void                    elm_fileselector_is_save_set(Evas_Object *obj, Eina_Bool is_save)
    Eina_Bool               elm_fileselector_is_save_get(const Evas_Object *obj)
    void                    elm_fileselector_folder_only_set(Evas_Object *obj, Eina_Bool value)
    Eina_Bool               elm_fileselector_folder_only_get(const Evas_Object *obj)
    void                    elm_fileselector_buttons_ok_cancel_set(Evas_Object *obj, Eina_Bool value)
    Eina_Bool               elm_fileselector_buttons_ok_cancel_get(const Evas_Object *obj)
    void                    elm_fileselector_expandable_set(Evas_Object *obj, Eina_Bool value)
    Eina_Bool               elm_fileselector_expandable_get(const Evas_Object *obj)
    void                    elm_fileselector_path_set(Evas_Object *obj, const char *path)
    const char *            elm_fileselector_path_get(const Evas_Object *obj)
    void                    elm_fileselector_mode_set(Evas_Object *obj, Elm_Fileselector_Mode mode)
    Elm_Fileselector_Mode   elm_fileselector_mode_get(const Evas_Object *obj)
    void                    elm_fileselector_multi_select_set(Evas_Object *obj, Eina_Bool multi)
    Eina_Bool               elm_fileselector_multi_select_get(const Evas_Object *obj)
    Eina_Bool               elm_fileselector_selected_set(Evas_Object *obj, const char *path)
    const char *            elm_fileselector_selected_get(const Evas_Object *obj)
    const Eina_List *       elm_fileselector_selected_paths_get(const Evas_Object *obj)
    Eina_Bool               elm_fileselector_mime_types_filter_append(Evas_Object *obj, const char *mime_types, const char *filter_name)
    Eina_Bool               elm_fileselector_custom_filter_append(Evas_Object *obj, Elm_Fileselector_Filter_Func func, void *data, const char *filter_name)
    void                    elm_fileselector_filters_clear(Evas_Object *obj)
    void                    elm_fileselector_hidden_visible_set(Evas_Object *obj, Eina_Bool visible)
    Eina_Bool               elm_fileselector_hidden_visible_get(const Evas_Object *obj)
    Elm_Fileselector_Sort   elm_fileselector_sort_method_get(const Evas_Object *obj)
    void                    elm_fileselector_sort_method_set(Evas_Object *obj, Elm_Fileselector_Sort method)
    void                    elm_fileselector_thumbnail_size_set(Evas_Object *obj, Evas_Coord w, Evas_Coord h)
    void                    elm_fileselector_thumbnail_size_get(const Evas_Object *obj, Evas_Coord *w, Evas_Coord *h)
    void                    elm_fileselector_current_name_set(Evas_Object *obj, const char *name)
    const char *            elm_fileselector_current_name_get(const Evas_Object *obj)