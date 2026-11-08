# PetCare

Aplicación para iPhone desarrollada con Swift y SwiftUI. El repositorio se llama Petpulse y el proyecto de Xcode se llama PetCare.

## Abrir el proyecto

1. Clona este repositorio en tu Mac.
2. Abre `PetCare.xcodeproj` con Xcode.
3. Selecciona el esquema PetCare y un simulador compatible con el destino iOS configurado en el proyecto.
4. Ejecuta la aplicación con **Run** (⌘R).

Para ejecutar en un iPhone físico, configura tu equipo de firma en **Signing & Capabilities**. El proyecto importado declara un destino mínimo iOS 26.4; se requiere una versión de Xcode con un SDK compatible.

## Estructura

- `PetCare/`: código Swift, pantallas, modelos y recursos.
- `PetCare.xcodeproj/`: configuración del proyecto de Xcode.

Incluye pantallas para registrar mascotas, seguimiento de salud, mapas y chat. Los datos de mascotas se guardan localmente con UserDefaults y los listados de lugares incluyen datos de ejemplo.

## Desarrollo

Trabaja en una rama para cada mejora, revisa los cambios y comprueba la aplicación en Xcode antes de integrarlos. Git conserva las versiones registradas mediante commits; GitHub almacena el repositorio remoto.

El entorno Linux permite editar y revisar el código, pero compilar y ejecutar esta aplicación iOS requiere macOS y Xcode. Esta importación conserva el código del ZIP original y no incluye una validación de compilación.
