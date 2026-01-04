"""
Módulo para la clase Paciente (mascota)
"""
from datetime import date


class Paciente:
    """Representa a un paciente (mascota) en la clínica veterinaria"""
    
    def __init__(self, id_paciente, nombre, especie, raza, fecha_nacimiento, tutor):
        """
        Inicializa un paciente
        
        Args:
            id_paciente: Identificador único del paciente
            nombre: Nombre de la mascota
            especie: Especie del animal (perro, gato, etc.)
            raza: Raza del animal
            fecha_nacimiento: Fecha de nacimiento (objeto date)
            tutor: Objeto Tutor dueño de la mascota
        """
        self.id_paciente = id_paciente
        self.nombre = nombre
        self.especie = especie
        self.raza = raza
        self.fecha_nacimiento = fecha_nacimiento
        self.tutor = tutor
        self.historial_medico = []
        
        # Agregar esta mascota al tutor
        tutor.agregar_mascota(self)
    
    def calcular_edad(self):
        """Calcula la edad del paciente en años"""
        hoy = date.today()
        edad = hoy.year - self.fecha_nacimiento.year
        if hoy.month < self.fecha_nacimiento.month or \
           (hoy.month == self.fecha_nacimiento.month and hoy.day < self.fecha_nacimiento.day):
            edad -= 1
        return edad
    
    def agregar_historial(self, registro):
        """Agrega un registro al historial médico"""
        self.historial_medico.append(registro)
    
    def __str__(self):
        return f"Paciente: {self.nombre} ({self.especie}) - Tutor: {self.tutor.obtener_nombre_completo()}"
    
    def __repr__(self):
        return f"Paciente(id={self.id_paciente}, nombre={self.nombre}, especie={self.especie})"
