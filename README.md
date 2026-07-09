# Catálogo de Precios

App móvil Flutter para que empleados de **una sola tienda** consulten precios de productos por nombre, en segundos, funcionando **100% offline**. No es un POS, no es inventario, no es ERP — es exclusivamente consulta de precios + administración básica de productos.

## Características Principales

*   **Offline-first:** La app siempre funciona con su base de datos local SQLite (`sqflite`). La consulta de precios está diseñada para ser ultra rápida sin depender de conexión a internet.
*   **Búsqueda Rápida:** Búsqueda inmediata de productos por coincidencia de texto, con enfoque en velocidad y simplicidad.
*   **Gestión de Catálogo:** Interfaz de administración básica para productos (crear, editar, ocultar), protegida de forma local mediante un PIN administrativo.
*   **Sincronización:** Capacidad para respaldar y sincronizar el catálogo local hacia y desde la nube mediante Supabase, asegurando que todos los dispositivos de la tienda (si hubiera más de uno) se mantengan actualizados a voluntad.

## Stack Tecnológico

*   **Framework:** Flutter (un solo codebase para el desarrollo).
*   **Base de Datos Local:** SQLite (mediante el paquete `sqflite`, con consultas SQL nativas).
*   **Backend / Nube:** Supabase (Postgres + Storage), utilizado para mantener una réplica de la base de datos en la nube y sincronizar datos.
*   **Autenticación Administrativa:** PIN local validado mediante hash.
*   **Arquitectura:** Feature-first con una separación en capas simples (`data`, `domain`, `presentation`) y el patrón MVVM.

## Arquitectura

El proyecto está organizado siguiendo un enfoque feature-first para separar claramente los módulos de la aplicación:

```text
lib/
├── core/               # Código base: base de datos, config de Supabase, temas y widgets comunes
└── features/
    ├── search/         # Búsqueda de productos (data, domain, presentation)
    ├── product_detail/ # Detalle del producto (presentation)
    ├── admin/          # CRUD de productos y validación de PIN (data, domain, presentation)
    └── sync/           # Lógica de sincronización con Supabase (data, domain, presentation)
```

### Reglas y Principios de Desarrollo

1.  **Un solo modelo de Producto:** Existe un único modelo de datos (`Product`) usado indistintamente entre SQLite y Supabase para minimizar el boilerplate. No hay clases DTO separadas sin necesidad.
2.  **Offline-first real:** La aplicación siempre lee y escribe primero en la base de datos local SQLite. La sincronización es un paso separado y explícito.
3.  **Simplicidad:** Se prefiere SQL puro y directo (`sqflite`) sobre ORMs generadores de código para reducir la barrera de mantenimiento y mantener el rendimiento máximo para este volumen de datos (< 500 productos).
4.  **Prioridad al uso del teclado:** La pantalla inicial enfoca automáticamente el campo de texto y despliega el teclado para permitir búsquedas instantáneas, sin toques adicionales.

## Protocolo de Sincronización

La aplicación sincroniza sus datos con un servidor Supabase siguiendo estas reglas clave:

1.  El orden es siempre **PUSH primero, PULL después** (envía cambios locales, luego baja cambios del servidor).
2.  En caso de conflictos, el servidor gana (*server wins*).
3.  La aplicación está configurada con Row Level Security (RLS) que acepta la `anon key` explícitamente configurada. Las credenciales de administrador nunca se compilan en el APK cliente.

## Instalación y Ejecución

1. Clonar el repositorio.
2. Ejecutar la descarga de dependencias:
   ```bash
   flutter pub get
   ```
3. Configurar las credenciales de Supabase (las URL de API y las `anon keys`). Asegúrate de que las credenciales están asignadas correctamente en los ficheros de configuración o entorno (e.g. `lib/core/supabase/env.dart`).
4. Compilar o lanzar la aplicación:
   ```bash
   flutter run
   ```
