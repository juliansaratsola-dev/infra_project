"""
Aplicación principal - Interfaz de línea de comandos
Sistema de Gestión de Citas Veterinarias
"""
from datetime import datetime, date
from sistema_veterinaria import SistemaVeterinaria


def mostrar_menu():
    """Muestra el menú principal"""
    print("\n" + "="*50)
    print("SISTEMA DE GESTIÓN VETERINARIA")
    print("="*50)
    print("1. Gestión de Tutores")
    print("2. Gestión de Pacientes")
    print("3. Gestión de Medicamentos")
    print("4. Gestión de Citas")
    print("5. Ver Estadísticas")
    print("6. Cargar Datos de Ejemplo")
    print("0. Salir")
    print("="*50)


def menu_tutores(sistema):
    """Menú para gestión de tutores"""
    while True:
        print("\n--- GESTIÓN DE TUTORES ---")
        print("1. Registrar nuevo tutor")
        print("2. Listar tutores")
        print("3. Buscar tutor")
        print("0. Volver")
        
        opcion = input("\nSeleccione opción: ")
        
        if opcion == "1":
            print("\n--- Registrar Tutor ---")
            nombre = input("Nombre: ")
            apellido = input("Apellido: ")
            telefono = input("Teléfono: ")
            email = input("Email: ")
            direccion = input("Dirección: ")
            
            tutor = sistema.registrar_tutor(nombre, apellido, telefono, email, direccion)
            print(f"\n✓ Tutor registrado exitosamente con ID: {tutor.id_tutor}")
        
        elif opcion == "2":
            print("\n--- Lista de Tutores ---")
            tutores = sistema.listar_tutores()
            if tutores:
                for tutor in tutores:
                    print(f"ID: {tutor.id_tutor} - {tutor}")
                    if tutor.mascotas:
                        print(f"  Mascotas: {', '.join([m.nombre for m in tutor.mascotas])}")
            else:
                print("No hay tutores registrados")
        
        elif opcion == "3":
            id_tutor = int(input("Ingrese ID del tutor: "))
            tutor = sistema.buscar_tutor(id_tutor)
            if tutor:
                print(f"\n{tutor}")
                print(f"Email: {tutor.email}")
                print(f"Dirección: {tutor.direccion}")
            else:
                print("Tutor no encontrado")
        
        elif opcion == "0":
            break


def menu_pacientes(sistema):
    """Menú para gestión de pacientes"""
    while True:
        print("\n--- GESTIÓN DE PACIENTES ---")
        print("1. Registrar nuevo paciente")
        print("2. Listar pacientes")
        print("3. Buscar paciente")
        print("4. Ver historial médico")
        print("0. Volver")
        
        opcion = input("\nSeleccione opción: ")
        
        if opcion == "1":
            print("\n--- Registrar Paciente ---")
            nombre = input("Nombre de la mascota: ")
            especie = input("Especie (perro/gato/etc): ")
            raza = input("Raza: ")
            
            print("Fecha de nacimiento:")
            year = int(input("  Año: "))
            month = int(input("  Mes: "))
            day = int(input("  Día: "))
            fecha_nacimiento = date(year, month, day)
            
            id_tutor = int(input("ID del tutor: "))
            
            try:
                paciente = sistema.registrar_paciente(nombre, especie, raza, fecha_nacimiento, id_tutor)
                print(f"\n✓ Paciente registrado exitosamente con ID: {paciente.id_paciente}")
            except ValueError as e:
                print(f"\n✗ Error: {e}")
        
        elif opcion == "2":
            print("\n--- Lista de Pacientes ---")
            pacientes = sistema.listar_pacientes()
            if pacientes:
                for paciente in pacientes:
                    print(f"ID: {paciente.id_paciente} - {paciente} - Edad: {paciente.calcular_edad()} años")
            else:
                print("No hay pacientes registrados")
        
        elif opcion == "3":
            id_paciente = int(input("Ingrese ID del paciente: "))
            paciente = sistema.buscar_paciente(id_paciente)
            if paciente:
                print(f"\n{paciente}")
                print(f"Raza: {paciente.raza}")
                print(f"Edad: {paciente.calcular_edad()} años")
                print(f"Fecha de nacimiento: {paciente.fecha_nacimiento}")
            else:
                print("Paciente no encontrado")
        
        elif opcion == "4":
            id_paciente = int(input("Ingrese ID del paciente: "))
            paciente = sistema.buscar_paciente(id_paciente)
            if paciente:
                print(f"\n--- Historial Médico de {paciente.nombre} ---")
                if paciente.historial_medico:
                    for i, registro in enumerate(paciente.historial_medico, 1):
                        print(f"\nRegistro {i}:")
                        print(f"  Fecha: {registro['fecha']}")
                        print(f"  Motivo: {registro['motivo']}")
                        print(f"  Diagnóstico: {registro['diagnostico']}")
                        print(f"  Tratamiento: {registro['tratamiento']}")
                        print(f"  Veterinario: {registro['veterinario']}")
                else:
                    print("No hay historial médico registrado")
            else:
                print("Paciente no encontrado")
        
        elif opcion == "0":
            break


def menu_medicamentos(sistema):
    """Menú para gestión de medicamentos"""
    while True:
        print("\n--- GESTIÓN DE MEDICAMENTOS ---")
        print("1. Registrar nuevo medicamento")
        print("2. Listar medicamentos")
        print("3. Buscar medicamento")
        print("0. Volver")
        
        opcion = input("\nSeleccione opción: ")
        
        if opcion == "1":
            print("\n--- Registrar Medicamento ---")
            nombre = input("Nombre: ")
            descripcion = input("Descripción: ")
            dosis = input("Dosis: ")
            frecuencia = input("Frecuencia: ")
            
            medicamento = sistema.registrar_medicamento(nombre, descripcion, dosis, frecuencia)
            print(f"\n✓ Medicamento registrado exitosamente con ID: {medicamento.id_medicamento}")
        
        elif opcion == "2":
            print("\n--- Lista de Medicamentos ---")
            medicamentos = sistema.listar_medicamentos()
            if medicamentos:
                for medicamento in medicamentos:
                    print(f"ID: {medicamento.id_medicamento} - {medicamento}")
            else:
                print("No hay medicamentos registrados")
        
        elif opcion == "3":
            id_medicamento = int(input("Ingrese ID del medicamento: "))
            medicamento = sistema.buscar_medicamento(id_medicamento)
            if medicamento:
                print(f"\n{medicamento}")
                print(f"Descripción: {medicamento.descripcion}")
            else:
                print("Medicamento no encontrado")
        
        elif opcion == "0":
            break


def menu_citas(sistema):
    """Menú para gestión de citas"""
    while True:
        print("\n--- GESTIÓN DE CITAS ---")
        print("1. Programar nueva cita")
        print("2. Listar citas")
        print("3. Buscar cita")
        print("4. Completar cita")
        print("5. Cancelar cita")
        print("6. Citas por fecha")
        print("0. Volver")
        
        opcion = input("\nSeleccione opción: ")
        
        if opcion == "1":
            print("\n--- Programar Cita ---")
            id_paciente = int(input("ID del paciente: "))
            
            print("Fecha y hora de la cita:")
            year = int(input("  Año: "))
            month = int(input("  Mes: "))
            day = int(input("  Día: "))
            hour = int(input("  Hora (0-23): "))
            minute = int(input("  Minuto: "))
            fecha_hora = datetime(year, month, day, hour, minute)
            
            motivo = input("Motivo de la consulta: ")
            veterinario = input("Nombre del veterinario: ")
            
            try:
                cita = sistema.programar_cita(id_paciente, fecha_hora, motivo, veterinario)
                print(f"\n✓ Cita programada exitosamente con ID: {cita.id_cita}")
            except ValueError as e:
                print(f"\n✗ Error: {e}")
        
        elif opcion == "2":
            print("\n--- Lista de Citas ---")
            print("Filtrar por estado? (dejar vacío para todas)")
            print("Opciones: programada, completada, cancelada, en_proceso")
            estado = input("Estado: ").strip() or None
            
            citas = sistema.listar_citas(estado)
            if citas:
                for cita in citas:
                    print(f"\n{cita}")
                    print(f"  Paciente: {cita.paciente.nombre} - Tutor: {cita.paciente.tutor.obtener_nombre_completo()}")
                    print(f"  Motivo: {cita.motivo}")
                    print(f"  Veterinario: {cita.veterinario}")
            else:
                print("No hay citas registradas")
        
        elif opcion == "3":
            id_cita = int(input("Ingrese ID de la cita: "))
            cita = sistema.buscar_cita(id_cita)
            if cita:
                print(f"\n{cita}")
                print(f"Paciente: {cita.paciente.nombre}")
                print(f"Tutor: {cita.paciente.tutor.obtener_nombre_completo()}")
                print(f"Motivo: {cita.motivo}")
                print(f"Veterinario: {cita.veterinario}")
                if cita.diagnostico:
                    print(f"Diagnóstico: {cita.diagnostico}")
                if cita.tratamiento:
                    print(f"Tratamiento: {cita.tratamiento}")
            else:
                print("Cita no encontrada")
        
        elif opcion == "4":
            id_cita = int(input("Ingrese ID de la cita: "))
            diagnostico = input("Diagnóstico: ")
            tratamiento = input("Tratamiento: ")
            notas = input("Notas adicionales: ")
            
            medicamentos = input("IDs de medicamentos recetados (separados por coma, vacío si no hay): ")
            medicamentos_ids = [int(x.strip()) for x in medicamentos.split(",")] if medicamentos else None
            
            try:
                cita = sistema.completar_cita(id_cita, diagnostico, tratamiento, medicamentos_ids, notas)
                print(f"\n✓ Cita completada exitosamente")
            except ValueError as e:
                print(f"\n✗ Error: {e}")
        
        elif opcion == "5":
            id_cita = int(input("Ingrese ID de la cita a cancelar: "))
            if sistema.cancelar_cita(id_cita):
                print("\n✓ Cita cancelada exitosamente")
            else:
                print("\n✗ Cita no encontrada")
        
        elif opcion == "6":
            print("Ingrese la fecha:")
            year = int(input("  Año: "))
            month = int(input("  Mes: "))
            day = int(input("  Día: "))
            fecha = date(year, month, day)
            
            citas = sistema.listar_citas_por_fecha(fecha)
            if citas:
                print(f"\n--- Citas del {fecha} ---")
                for cita in citas:
                    print(f"{cita}")
            else:
                print(f"No hay citas para el {fecha}")
        
        elif opcion == "0":
            break


def cargar_datos_ejemplo(sistema):
    """Carga datos de ejemplo en el sistema"""
    print("\n--- Cargando datos de ejemplo ---")
    
    # Tutores
    tutor1 = sistema.registrar_tutor("Juan", "Pérez", "555-1234", "juan@email.com", "Calle 123")
    tutor2 = sistema.registrar_tutor("María", "González", "555-5678", "maria@email.com", "Avenida 456")
    print("✓ Tutores registrados")
    
    # Pacientes
    paciente1 = sistema.registrar_paciente("Max", "Perro", "Labrador", date(2020, 5, 15), tutor1.id_tutor)
    paciente2 = sistema.registrar_paciente("Luna", "Gato", "Siamés", date(2019, 8, 20), tutor1.id_tutor)
    paciente3 = sistema.registrar_paciente("Rocky", "Perro", "Bulldog", date(2021, 3, 10), tutor2.id_tutor)
    print("✓ Pacientes registrados")
    
    # Medicamentos
    med1 = sistema.registrar_medicamento("Amoxicilina", "Antibiótico", "10mg/kg", "Cada 12 horas")
    med2 = sistema.registrar_medicamento("Rimadyl", "Antiinflamatorio", "2mg/kg", "Cada 24 horas")
    med3 = sistema.registrar_medicamento("Frontline", "Antiparasitario", "Aplicación tópica", "Mensual")
    print("✓ Medicamentos registrados")
    
    # Citas
    cita1 = sistema.programar_cita(paciente1.id_paciente, datetime(2026, 1, 15, 10, 0), "Vacunación anual", "Dr. Rodríguez")
    cita2 = sistema.programar_cita(paciente2.id_paciente, datetime(2026, 1, 16, 14, 30), "Control general", "Dra. Martínez")
    cita3 = sistema.programar_cita(paciente3.id_paciente, datetime(2026, 1, 17, 9, 0), "Dolor en pata", "Dr. Rodríguez")
    print("✓ Citas programadas")
    
    # Completar una cita de ejemplo
    sistema.completar_cita(cita2.id_cita, "Estado de salud excelente", "Continuar con dieta actual", [med3.id_medicamento], "Gato muy sociable")
    print("✓ Cita de ejemplo completada")
    
    print("\n✓ Datos de ejemplo cargados exitosamente")


def ver_estadisticas(sistema):
    """Muestra estadísticas del sistema"""
    stats = sistema.obtener_estadisticas()
    print("\n" + "="*50)
    print("ESTADÍSTICAS DEL SISTEMA")
    print("="*50)
    print(f"Total de Tutores:        {stats['total_tutores']}")
    print(f"Total de Pacientes:      {stats['total_pacientes']}")
    print(f"Total de Medicamentos:   {stats['total_medicamentos']}")
    print(f"Total de Citas:          {stats['total_citas']}")
    print(f"  - Programadas:         {stats['citas_programadas']}")
    print(f"  - Completadas:         {stats['citas_completadas']}")
    print(f"  - Canceladas:          {stats['citas_canceladas']}")
    print("="*50)


def main():
    """Función principal"""
    sistema = SistemaVeterinaria()
    
    print("\n¡Bienvenido al Sistema de Gestión Veterinaria!")
    
    while True:
        mostrar_menu()
        opcion = input("\nSeleccione una opción: ")
        
        if opcion == "1":
            menu_tutores(sistema)
        elif opcion == "2":
            menu_pacientes(sistema)
        elif opcion == "3":
            menu_medicamentos(sistema)
        elif opcion == "4":
            menu_citas(sistema)
        elif opcion == "5":
            ver_estadisticas(sistema)
        elif opcion == "6":
            cargar_datos_ejemplo(sistema)
        elif opcion == "0":
            print("\n¡Gracias por usar el Sistema de Gestión Veterinaria!")
            print("¡Hasta pronto!")
            break
        else:
            print("\n✗ Opción inválida, por favor intente de nuevo")


if __name__ == "__main__":
    main()
