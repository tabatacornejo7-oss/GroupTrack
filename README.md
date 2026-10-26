# GroupTrack

Aplicación web estática para coordinar proyectos académicos, con Supabase como backend y GitHub Pages como hosting.

## Configuración inicial de Supabase

1. En **Authentication → Providers → Email**, desactiva **Confirm email**. GroupTrack usa nombre y contraseña, y genera internamente un identificador de correo no destinado a recibir mensajes.
2. Abre **SQL Editor → New query**, pega el contenido de `supabase-schema.sql` y pulsa **Run**. Esto crea perfiles, proyectos, permisos RLS, invitaciones por código y almacenamiento privado para documentos.
3. En **Authentication → URL Configuration**, añade `https://tabatacornejo7-oss.github.io` a los redirect URLs permitidos.
4. Abre la web y crea una cuenta con nombre único y contraseña de al menos 8 caracteres.

La URL y publishable key del proyecto están en `app.js`; la publishable key es pública por diseño. Nunca añadas una clave `secret` o `service_role` al frontend.

## Publicación

El workflow `.github/workflows/deploy.yml` publica el repositorio con GitHub Pages al actualizar `main`. La fuente de Pages debe estar en **Settings → Pages → Build and deployment → Source: GitHub Actions**.

## Notas

- Perfiles, proyectos, tareas, eventos y metadatos de documentos se guardan en Supabase y se comparten entre miembros.
- Los archivos se suben al bucket privado `grouptrack-documents`.
- Como el acceso se hace con nombre y contraseña sin correo real, la recuperación de contraseña no está disponible. Los usuarios deben guardar sus contraseñas.
- Los proyectos guardados previamente en este navegador se importan al iniciar sesión por primera vez con el mismo nombre.

