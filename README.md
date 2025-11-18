# GestAsocia

**GestAsocia** es un sistema tipo **SaaS para escritorio (Windows)** diseñado para la **gestión integral de asociados, cargas familiares, historial clínico y reservas de horas**.  
La aplicación es **solo Desktop**, no está pensada para web ni dispositivos móviles.  
Está desarrollada en **Flutter Desktop** y utiliza **Firebase** como backend.

Repositorio: [https://github.com/benjamon19/Software_desktop_Gestasocia.git](https://github.com/benjamon19/Software_desktop_Gestasocia.git)

---

## Login

**Login con tema oscuro**  
![Login oscuro](assets/screenshots/login-oscuro.png)

**Login con tema claro**  
![Login claro](assets/screenshots/login-claro.png)

**Código de acceso doble factor**  
![Código de acceso](assets/screenshots/codigo.png)

---

## Dashboard

El **dashboard** muestra gráficas, cartas y estadísticas principales de la aplicación.


---

## Gestión de asociados

Permite:

- Búsqueda por SAP, RUT o código de barras.  
- CRUD completo de asociados.  
- Exportación de datos y acceso a historial.  

**Vista asociado**  
![Vista asociado](assets/screenshots/vista-asociado.png)

---

## Gestión de cargas familiares

Permite:

- CRUD completo de cargas.  
- Transferencia de cargas entre asociados.  
- Exportación de datos e historial.   

**Vista carga**  
![Vista carga](assets/screenshots/vista-carga.png)

---

## Gestión de historial clínico

Permite:

- CRUD completo de registros clínicos.  
- Exportación de datos e historial.  
- Adjuntar documentos (radiografías) usando Storage. 

**Vista historial**  
![Vista historial](assets/screenshots/vista-historial.png)

---

## Gestión de perfil y configuración

- Actualización de información personal.  
- Cambio de foto mediante Storage.  
- Cierre de sesión.  
- Configuración de la aplicación según roles.

---

## Arquitectura del proyecto

Aplicación modular basada en 3 capas:

```bash
lib/
│
├─ bindings/
├─ config/
├─ controllers/
├─ dialogs/
├─ models/
├─ pages/
│ ├─ dashboard/
│ │ ├─ main_view.dart
│ │ └─ sections/...
│ ├─ perfil/
│ │ ├─ main_view.dart
│ │ └─ sections/...
│ └─ configuracion/
│ ├─ main_view.dart
│ └─ sections/...
│
├─ modules/
│ ├─ gestion_asociados/
│ │ ├─ main_view.dart
│ │ └─ sections/...
│ ├─ gestion_cargas_familiares/
│ │ ├─ main_view.dart
│ │ └─ sections/...
│ ├─ gestion_historial_clinico/
│ │ ├─ main_view.dart
│ │ └─ sections/...
│ └─ gestion_reserva_horas/
│ ├─ main_view.dart
│ └─ sections/...
│
├─ shared/
│ ├─ dialogs/
│ ├─ widgets/
│ └─ main_view.dart
│
└─ utils/
```
---

## Tecnologías usadas

- Flutter Desktop (UI y lógica de la app).  
- Firebase Auth (autenticación).  
- Firestore (base de datos).  
- Firebase Storage (archivos y fotos).  
- GetX (gestión de estado y rutas).  
- Shared Preferences (almacenamiento local).  

---

## Instalación y ejecución

1. Clonar el repositorio:

```bash
git clone https://github.com/benjamon19/Software_desktop_Gestasocia.git
cd Software_desktop_Gestasocia
```

2. Instalar dependencias:

```bash
flutter pub get
```

3. Ejecutar la app en Windows:

```bash
flutter run -d windows
```