"""
Sistema de Gestión de Citas Veterinarias
Aplicación orientada a objetos para la administración de citas veterinarias
"""

__version__ = "1.0.0"
__author__ = "Veterinary System"

from .tutor import Tutor
from .paciente import Paciente
from .medicamentos import Medicamento
from .cita import Cita
from .sistema_veterinaria import SistemaVeterinaria

__all__ = [
    'Tutor',
    'Paciente',
    'Medicamento',
    'Cita',
    'SistemaVeterinaria'
]
