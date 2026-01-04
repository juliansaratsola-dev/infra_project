"""
Módulo para la clase Medicamentos
"""


class Medicamento:
    """Representa un medicamento en el sistema veterinario"""
    
    def __init__(self, id_medicamento, nombre, descripcion, dosis, frecuencia):
        """
        Inicializa un medicamento
        
        Args:
            id_medicamento: Identificador único del medicamento
            nombre: Nombre del medicamento
            descripcion: Descripción del medicamento
            dosis: Dosis recomendada
            frecuencia: Frecuencia de administración
        """
        self.id_medicamento = id_medicamento
        self.nombre = nombre
        self.descripcion = descripcion
        self.dosis = dosis
        self.frecuencia = frecuencia
    
    def __str__(self):
        return f"Medicamento: {self.nombre} - Dosis: {self.dosis}, Frecuencia: {self.frecuencia}"
    
    def __repr__(self):
        return f"Medicamento(id={self.id_medicamento}, nombre={self.nombre})"
