"""
Sistema de Gestión de Citas Veterinarias
Aplicación principal para administrar citas, tutores, pacientes y medicamentos
"""
from datetime import datetime, date
from tutor import Tutor
from paciente import Paciente
from medicamentos import Medicamento
from cita import Cita


class SistemaVeterinaria:
    """Sistema principal de gestión de la clínica veterinaria"""
    
    def __init__(self):
        """Inicializa el sistema"""
        self.tutores = {}
        self.pacientes = {}
        self.medicamentos = {}
        self.citas = {}
        self.id_tutor_counter = 1
        self.id_paciente_counter = 1
        self.id_medicamento_counter = 1
        self.id_cita_counter = 1
    
    # Gestión de Tutores
    def registrar_tutor(self, nombre, apellido, telefono, email, direccion):
        """Registra un nuevo tutor en el sistema"""
        tutor = Tutor(self.id_tutor_counter, nombre, apellido, telefono, email, direccion)
        self.tutores[self.id_tutor_counter] = tutor
        self.id_tutor_counter += 1
        return tutor
    
    def buscar_tutor(self, id_tutor):
        """Busca un tutor por ID"""
        return self.tutores.get(id_tutor)
    
    def listar_tutores(self):
        """Lista todos los tutores registrados"""
        return list(self.tutores.values())
    
    # Gestión de Pacientes
    def registrar_paciente(self, nombre, especie, raza, fecha_nacimiento, id_tutor):
        """Registra un nuevo paciente en el sistema"""
        tutor = self.buscar_tutor(id_tutor)
        if not tutor:
            raise ValueError(f"Tutor con ID {id_tutor} no encontrado")
        
        paciente = Paciente(self.id_paciente_counter, nombre, especie, raza, fecha_nacimiento, tutor)
        self.pacientes[self.id_paciente_counter] = paciente
        self.id_paciente_counter += 1
        return paciente
    
    def buscar_paciente(self, id_paciente):
        """Busca un paciente por ID"""
        return self.pacientes.get(id_paciente)
    
    def listar_pacientes(self):
        """Lista todos los pacientes registrados"""
        return list(self.pacientes.values())
    
    def listar_pacientes_por_tutor(self, id_tutor):
        """Lista los pacientes de un tutor específico"""
        tutor = self.buscar_tutor(id_tutor)
        if tutor:
            return tutor.mascotas
        return []
    
    # Gestión de Medicamentos
    def registrar_medicamento(self, nombre, descripcion, dosis, frecuencia):
        """Registra un nuevo medicamento en el sistema"""
        medicamento = Medicamento(self.id_medicamento_counter, nombre, descripcion, dosis, frecuencia)
        self.medicamentos[self.id_medicamento_counter] = medicamento
        self.id_medicamento_counter += 1
        return medicamento
    
    def buscar_medicamento(self, id_medicamento):
        """Busca un medicamento por ID"""
        return self.medicamentos.get(id_medicamento)
    
    def listar_medicamentos(self):
        """Lista todos los medicamentos registrados"""
        return list(self.medicamentos.values())
    
    # Gestión de Citas
    def programar_cita(self, id_paciente, fecha_hora, motivo, veterinario):
        """Programa una nueva cita"""
        paciente = self.buscar_paciente(id_paciente)
        if not paciente:
            raise ValueError(f"Paciente con ID {id_paciente} no encontrado")
        
        cita = Cita(self.id_cita_counter, paciente, fecha_hora, motivo, veterinario)
        self.citas[self.id_cita_counter] = cita
        self.id_cita_counter += 1
        return cita
    
    def buscar_cita(self, id_cita):
        """Busca una cita por ID"""
        return self.citas.get(id_cita)
    
    def listar_citas(self, estado=None):
        """Lista todas las citas, opcionalmente filtradas por estado"""
        citas = list(self.citas.values())
        if estado:
            citas = [c for c in citas if c.estado == estado]
        return citas
    
    def listar_citas_por_fecha(self, fecha):
        """Lista las citas de una fecha específica"""
        return [c for c in self.citas.values() if c.fecha_hora.date() == fecha]
    
    def listar_citas_por_paciente(self, id_paciente):
        """Lista las citas de un paciente específico"""
        return [c for c in self.citas.values() if c.paciente.id_paciente == id_paciente]
    
    def cancelar_cita(self, id_cita):
        """Cancela una cita"""
        cita = self.buscar_cita(id_cita)
        if cita:
            cita.cambiar_estado('cancelada')
            return True
        return False
    
    def completar_cita(self, id_cita, diagnostico, tratamiento, medicamentos_ids=None, notas=""):
        """Completa una cita con diagnóstico, tratamiento y medicamentos"""
        cita = self.buscar_cita(id_cita)
        if not cita:
            raise ValueError(f"Cita con ID {id_cita} no encontrada")
        
        # Agregar medicamentos si se proporcionaron
        if medicamentos_ids:
            for med_id in medicamentos_ids:
                medicamento = self.buscar_medicamento(med_id)
                if medicamento:
                    cita.recetar_medicamento(medicamento)
        
        cita.completar_cita(diagnostico, tratamiento, notas)
        return cita
    
    # Utilidades
    def obtener_estadisticas(self):
        """Obtiene estadísticas generales del sistema"""
        return {
            'total_tutores': len(self.tutores),
            'total_pacientes': len(self.pacientes),
            'total_medicamentos': len(self.medicamentos),
            'total_citas': len(self.citas),
            'citas_programadas': len([c for c in self.citas.values() if c.estado == 'programada']),
            'citas_completadas': len([c for c in self.citas.values() if c.estado == 'completada']),
            'citas_canceladas': len([c for c in self.citas.values() if c.estado == 'cancelada'])
        }
