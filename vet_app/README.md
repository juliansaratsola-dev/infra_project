# Sistema de Gestión de Citas Veterinarias

Aplicación orientada a objetos en Python para la administración y registro de citas veterinarias.

## Descripción

Este sistema permite gestionar una clínica veterinaria completa, incluyendo:
- Registro de tutores (dueños de mascotas)
- Registro de pacientes (mascotas)
- Catálogo de medicamentos
- Programación y gestión de citas veterinarias
- Historial médico de pacientes

## Arquitectura

La aplicación está diseñada con programación orientada a objetos usando las siguientes clases principales:

### Clases del Sistema

1. **Tutor** (`tutor.py`)
   - Representa al dueño de una mascota
   - Atributos: ID, nombre, apellido, teléfono, email, dirección
   - Puede tener múltiples mascotas asociadas

2. **Paciente** (`paciente.py`)
   - Representa a una mascota (paciente)
   - Atributos: ID, nombre, especie, raza, fecha de nacimiento, tutor
   - Mantiene historial médico
   - Calcula edad automáticamente

3. **Medicamento** (`medicamentos.py`)
   - Representa medicamentos disponibles
   - Atributos: ID, nombre, descripción, dosis, frecuencia

4. **Cita** (`cita.py`)
   - Representa una cita veterinaria
   - Atributos: ID, paciente, fecha/hora, motivo, veterinario, estado
   - Estados: programada, completada, cancelada, en_proceso
   - Puede incluir diagnóstico, tratamiento y medicamentos recetados

5. **SistemaVeterinaria** (`sistema_veterinaria.py`)
   - Clase principal que gestiona todo el sistema
   - Administra tutores, pacientes, medicamentos y citas
   - Proporciona métodos para todas las operaciones del sistema

## Uso

### Instalación

No requiere dependencias externas, solo Python 3.6+

```bash
cd vet_app
python main.py
```

### Interfaz de Línea de Comandos

La aplicación incluye una interfaz interactiva (`main.py`) con las siguientes opciones:

1. **Gestión de Tutores**: Registrar y consultar dueños de mascotas
2. **Gestión de Pacientes**: Registrar mascotas y ver su historial
3. **Gestión de Medicamentos**: Administrar catálogo de medicamentos
4. **Gestión de Citas**: Programar, completar y cancelar citas
5. **Estadísticas**: Ver resumen del sistema
6. **Datos de Ejemplo**: Cargar datos de prueba

### Uso Programático

También puedes usar el sistema directamente en tu código:

```python
from datetime import datetime, date
from sistema_veterinaria import SistemaVeterinaria

# Inicializar sistema
sistema = SistemaVeterinaria()

# Registrar tutor
tutor = sistema.registrar_tutor("Juan", "Pérez", "555-1234", 
                                "juan@email.com", "Calle 123")

# Registrar paciente
paciente = sistema.registrar_paciente("Max", "Perro", "Labrador", 
                                      date(2020, 5, 15), tutor.id_tutor)

# Programar cita
cita = sistema.programar_cita(paciente.id_paciente, 
                              datetime(2026, 1, 15, 10, 0),
                              "Vacunación anual", "Dr. Rodríguez")

# Completar cita
sistema.completar_cita(cita.id_cita, 
                       "Estado de salud excelente",
                       "Aplicar vacuna antirrábica")
```

## Estructura de Archivos

```
vet_app/
├── __init__.py              # Inicialización del paquete
├── tutor.py                 # Clase Tutor
├── paciente.py              # Clase Paciente
├── medicamentos.py          # Clase Medicamento
├── cita.py                  # Clase Cita
├── sistema_veterinaria.py   # Sistema principal
├── main.py                  # Aplicación CLI
└── README.md               # Documentación
```

## Características

- ✅ Programación orientada a objetos
- ✅ Gestión completa de tutores y pacientes
- ✅ Sistema de citas con estados
- ✅ Historial médico de pacientes
- ✅ Catálogo de medicamentos
- ✅ Interfaz de línea de comandos interactiva
- ✅ Carga de datos de ejemplo
- ✅ Estadísticas del sistema

## Integración con Infraestructura

Esta aplicación está diseñada para ser desplegada en un entorno de infraestructura usando:
- RKE2 (Rancher Kubernetes Engine 2)
- Rancher para gestión de clusters
- Kubernetes para orquestación
- Terraform para infraestructura como código

La aplicación puede ser containerizada usando Docker y desplegada en el cluster K8s.

## Ejemplo de Containerización

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY vet_app/ /app/
CMD ["python", "main.py"]
```

## Licencia

Este proyecto es parte de un proyecto de infraestructura educativo.
