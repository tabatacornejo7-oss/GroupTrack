# GroupTrack

Prototipo estático web para coordinar proyectos académicos.

## Publicación

El workflow `.github/workflows/deploy.yml` publica el contenido del repositorio con GitHub Pages al actualizar `main`. En el repositorio, configura **Settings → Pages → Build and deployment → Source: GitHub Actions** para habilitar el primer despliegue.

## Límites de esta demo

Los perfiles, proyectos y tareas se guardan en el almacenamiento local del navegador. La página estará disponible desde distintos dispositivos, pero los datos no se sincronizan entre ellos. Para colaboración real entre usuarios hace falta conectar un backend y una base de datos compartida. Los documentos seleccionados están disponibles únicamente durante la sesión del navegador.

