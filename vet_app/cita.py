"""
Módulo para la clase Cita
"""
from datetime import datetime


class Cita:
    """Representa una cita veterinaria"""
    
    ESTADOS_VALIDOS = ['programada', 'completada', 'cancelada', 'en_proceso']
    
    def __init__(self, id_cita, paciente, fecha_hora, motivo, veterinario):
        """
        Inicializa una cita
        
        Args:
            id_cita: Identificador único de la cita
            paciente: Objeto Paciente
            fecha_hora: Fecha y hora de la cita (objeto datetime)
            motivo: Motivo de la consulta
            veterinario: Nombre del veterinario
        """
        self.id_cita = id_cita
        self.paciente = paciente
        self.fecha_hora = fecha_hora
        self.motivo = motivo
        self.veterinario = veterinario
        self.estado = 'programada'
        self.diagnostico = None
        self.tratamiento = None
        self.medicamentos_recetados = []
        self.notas = ""
    
    def cambiar_estado(self, nuevo_estado):
        """Cambia el estado de la cita"""
        if nuevo_estado in self.ESTADOS_VALIDOS:
            self.estado = nuevo_estado
        else:
            raise ValueError(f"Estado inválido. Debe ser uno de: {', '.join(self.ESTADOS_VALIDOS)}")
    
    def agregar_diagnostico(self, diagnostico):
        """Agrega un diagnóstico a la cita"""
        self.diagnostico = diagnostico
    
    def agregar_tratamiento(self, tratamiento):
        """Agrega un tratamiento a la cita"""
        self.tratamiento = tratamiento
    
    def recetar_medicamento(self, medicamento):
        """Agrega un medicamento recetado a la cita"""
        if medicamento not in self.medicamentos_recetados:
            self.medicamentos_recetados.append(medicamento)
    
    def agregar_notas(self, notas):
        """Agrega notas adicionales a la cita"""
        self.notas = notas
    
    def completar_cita(self, diagnostico, tratamiento, notas=""):
        """Completa la cita con diagnóstico y tratamiento"""
        self.diagnostico = diagnostico
        self.tratamiento = tratamiento
        self.notas = notas
        self.estado = 'completada'
        
        # Agregar al historial del paciente
        registro = {
            'fecha': self.fecha_hora,
            'motivo': self.motivo,
            'diagnostico': diagnostico,
            'tratamiento': tratamiento,
            'veterinario': self.veterinario,
            'medicamentos': self.medicamentos_recetados
        }
        self.paciente.agregar_historial(registro)
    
    def __str__(self):
        fecha_str = self.fecha_hora.strftime("%Y-%m-%d %H:%M")
        return f"Cita #{self.id_cita} - {self.paciente.nombre} - {fecha_str} - Estado: {self.estado}"
    
    def __repr__(self):
        return f"Cita(id={self.id_cita}, paciente={self.paciente.nombre}, estado={self.estado})"
