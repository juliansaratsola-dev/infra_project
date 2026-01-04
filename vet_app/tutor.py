"""
Módulo para la clase Tutor (dueño de mascota)
"""


class Tutor:
    """Representa al tutor o dueño de una mascota"""
    
    def __init__(self, id_tutor, nombre, apellido, telefono, email, direccion):
        """
        Inicializa un tutor
        
        Args:
            id_tutor: Identificador único del tutor
            nombre: Nombre del tutor
            apellido: Apellido del tutor
            telefono: Número de teléfono
            email: Correo electrónico
            direccion: Dirección del tutor
        """
        self.id_tutor = id_tutor
        self.nombre = nombre
        self.apellido = apellido
        self.telefono = telefono
        self.email = email
        self.direccion = direccion
        self.mascotas = []
    
    def agregar_mascota(self, mascota):
        """Agrega una mascota a la lista de mascotas del tutor"""
        if mascota not in self.mascotas:
            self.mascotas.append(mascota)
    
    def obtener_nombre_completo(self):
        """Retorna el nombre completo del tutor"""
        return f"{self.nombre} {self.apellido}"
    
    def __str__(self):
        return f"Tutor: {self.obtener_nombre_completo()} - Tel: {self.telefono}"
    
    def __repr__(self):
        return f"Tutor(id={self.id_tutor}, nombre={self.nombre}, apellido={self.apellido})"
