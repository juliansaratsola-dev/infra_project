"""
Ejemplo de uso del sistema de gestión veterinaria
Demuestra las funcionalidades principales del sistema
"""
from datetime import datetime, date
from sistema_veterinaria import SistemaVeterinaria


def ejemplo_completo():
    """Ejemplo completo de uso del sistema"""
    print("="*60)
    print("EJEMPLO DE USO - SISTEMA DE GESTIÓN VETERINARIA")
    print("="*60)
    
    # Crear instancia del sistema
    sistema = SistemaVeterinaria()
    
    # 1. Registrar Tutores
    print("\n1. REGISTRANDO TUTORES...")
    tutor1 = sistema.registrar_tutor(
        nombre="Juan",
        apellido="Pérez",
        telefono="555-1234",
        email="juan.perez@email.com",
        direccion="Calle Principal 123, Ciudad"
    )
    print(f"   ✓ {tutor1}")
    
    tutor2 = sistema.registrar_tutor(
        nombre="María",
        apellido="González",
        telefono="555-5678",
        email="maria.gonzalez@email.com",
        direccion="Avenida Central 456, Ciudad"
    )
    print(f"   ✓ {tutor2}")
    
    # 2. Registrar Pacientes (Mascotas)
    print("\n2. REGISTRANDO PACIENTES...")
    paciente1 = sistema.registrar_paciente(
        nombre="Max",
        especie="Perro",
        raza="Labrador Retriever",
        fecha_nacimiento=date(2020, 5, 15),
        id_tutor=tutor1.id_tutor
    )
    print(f"   ✓ {paciente1} - Edad: {paciente1.calcular_edad()} años")
    
    paciente2 = sistema.registrar_paciente(
        nombre="Luna",
        especie="Gato",
        raza="Siamés",
        fecha_nacimiento=date(2019, 8, 20),
        id_tutor=tutor1.id_tutor
    )
    print(f"   ✓ {paciente2} - Edad: {paciente2.calcular_edad()} años")
    
    paciente3 = sistema.registrar_paciente(
        nombre="Rocky",
        especie="Perro",
        raza="Bulldog Francés",
        fecha_nacimiento=date(2021, 3, 10),
        id_tutor=tutor2.id_tutor
    )
    print(f"   ✓ {paciente3} - Edad: {paciente3.calcular_edad()} años")
    
    # 3. Registrar Medicamentos
    print("\n3. REGISTRANDO MEDICAMENTOS...")
    med1 = sistema.registrar_medicamento(
        nombre="Amoxicilina",
        descripcion="Antibiótico de amplio espectro",
        dosis="10mg/kg",
        frecuencia="Cada 12 horas por 7 días"
    )
    print(f"   ✓ {med1}")
    
    med2 = sistema.registrar_medicamento(
        nombre="Rimadyl",
        descripcion="Antiinflamatorio no esteroideo",
        dosis="2mg/kg",
        frecuencia="Cada 24 horas"
    )
    print(f"   ✓ {med2}")
    
    med3 = sistema.registrar_medicamento(
        nombre="Frontline",
        descripcion="Antiparasitario tópico",
        dosis="Aplicación según peso",
        frecuencia="Una vez al mes"
    )
    print(f"   ✓ {med3}")
    
    # 4. Programar Citas
    print("\n4. PROGRAMANDO CITAS...")
    cita1 = sistema.programar_cita(
        id_paciente=paciente1.id_paciente,
        fecha_hora=datetime(2026, 1, 15, 10, 0),
        motivo="Vacunación anual y chequeo general",
        veterinario="Dr. Rodríguez"
    )
    print(f"   ✓ {cita1}")
    
    cita2 = sistema.programar_cita(
        id_paciente=paciente2.id_paciente,
        fecha_hora=datetime(2026, 1, 16, 14, 30),
        motivo="Control de rutina",
        veterinario="Dra. Martínez"
    )
    print(f"   ✓ {cita2}")
    
    cita3 = sistema.programar_cita(
        id_paciente=paciente3.id_paciente,
        fecha_hora=datetime(2026, 1, 17, 9, 0),
        motivo="Cojera en pata trasera derecha",
        veterinario="Dr. Rodríguez"
    )
    print(f"   ✓ {cita3}")
    
    # 5. Completar una cita
    print("\n5. COMPLETANDO CITA...")
    sistema.completar_cita(
        id_cita=cita2.id_cita,
        diagnostico="Estado de salud excelente. Peso adecuado para la edad.",
        tratamiento="Continuar con dieta actual. Aplicar antiparasitario.",
        medicamentos_ids=[med3.id_medicamento],
        notas="Gato muy sociable y tranquilo durante la consulta."
    )
    print(f"   ✓ Cita #{cita2.id_cita} completada")
    
    # 6. Ver historial del paciente
    print(f"\n6. HISTORIAL MÉDICO DE {paciente2.nombre}...")
    if paciente2.historial_medico:
        for i, registro in enumerate(paciente2.historial_medico, 1):
            print(f"\n   Registro {i}:")
            print(f"   - Fecha: {registro['fecha'].strftime('%Y-%m-%d %H:%M')}")
            print(f"   - Motivo: {registro['motivo']}")
            print(f"   - Diagnóstico: {registro['diagnostico']}")
            print(f"   - Tratamiento: {registro['tratamiento']}")
            print(f"   - Veterinario: {registro['veterinario']}")
            if registro['medicamentos']:
                print(f"   - Medicamentos: {', '.join([m.nombre for m in registro['medicamentos']])}")
    
    # 7. Listar citas programadas
    print("\n7. CITAS PROGRAMADAS...")
    citas_programadas = sistema.listar_citas(estado='programada')
    for cita in citas_programadas:
        print(f"   • {cita}")
        print(f"     Paciente: {cita.paciente.nombre} - Tutor: {cita.paciente.tutor.obtener_nombre_completo()}")
    
    # 8. Estadísticas
    print("\n8. ESTADÍSTICAS DEL SISTEMA...")
    stats = sistema.obtener_estadisticas()
    print(f"   Total de Tutores:      {stats['total_tutores']}")
    print(f"   Total de Pacientes:    {stats['total_pacientes']}")
    print(f"   Total de Medicamentos: {stats['total_medicamentos']}")
    print(f"   Total de Citas:        {stats['total_citas']}")
    print(f"     - Programadas:       {stats['citas_programadas']}")
    print(f"     - Completadas:       {stats['citas_completadas']}")
    print(f"     - Canceladas:        {stats['citas_canceladas']}")
    
    # 9. Cancelar una cita
    print("\n9. CANCELANDO CITA...")
    if sistema.cancelar_cita(cita3.id_cita):
        print(f"   ✓ Cita #{cita3.id_cita} cancelada exitosamente")
    
    print("\n" + "="*60)
    print("EJEMPLO COMPLETADO EXITOSAMENTE")
    print("="*60)


if __name__ == "__main__":
    ejemplo_completo()
