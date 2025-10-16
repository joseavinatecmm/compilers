#ifndef CLASE_H
#define CLASE_H

class Clase {
private:
    int id;
protected:
    float valor;
public:
    void setValor(float x);
    float promedio(float a, int n);
    MiClase* obtenerObjeto();
    int sumar(int a, int b);
    void iniciar();
};

#endif

