from efl.evas cimport Eina_Bool, Eina_List, Evas_Object, Evas_Coord

cdef extern from "Elementary.h":
    Evas_Object             *elm_grid_add(Evas_Object *parent)
    void                     elm_grid_size_set(Evas_Object *obj, Evas_Coord w, Evas_Coord h)
    void                     elm_grid_size_get(const Evas_Object *obj, Evas_Coord *w, Evas_Coord *h)
    void                     elm_grid_pack(Evas_Object *obj, Evas_Object *subobj, Evas_Coord x, Evas_Coord y, Evas_Coord w, Evas_Coord h)
    void                     elm_grid_unpack(Evas_Object *obj, Evas_Object *subobj)
    void                     elm_grid_clear(Evas_Object *obj, Eina_Bool clear)
    void                     elm_grid_pack_set(Evas_Object *subobj, Evas_Coord x, Evas_Coord y, Evas_Coord w, Evas_Coord h)
    void                     elm_grid_pack_get(const Evas_Object *subobj, Evas_Coord *x, Evas_Coord *y, Evas_Coord *w, Evas_Coord *h)
    Eina_List               *elm_grid_children_get(const Evas_Object *obj)

