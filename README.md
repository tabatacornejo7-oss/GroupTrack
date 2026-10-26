# GroupTrack

Prototipo estático web para coordinar proyectos académicos.

## Probar

La web se publica con GitHub Pages desde la rama `main`. En la pantalla inicial puedes registrarte con un nombre único o pulsar **Probar con un ejemplo** para abrir un proyecto de muestra.

Los datos de registro, proyectos y tareas se guardan en el navegador mediante almacenamiento local. Esto permite probar el prototipo sin configurar un servidor, pero los datos no se sincronizan entre navegadores o dispositivos.

## Publicación

El workflow `.github/workflows/deploy.yml` publica el sitio cuando hay cambios en `main`. La fuente de Pages debe estar en **Settings → Pages → Build and deployment → Source: GitHub Actions**.
