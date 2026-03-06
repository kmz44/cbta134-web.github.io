-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.about_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  logo_url text NOT NULL,
  croquis_image_url text,
  history_text text NOT NULL,
  mission_text text NOT NULL,
  vision_text text NOT NULL,
  lema_text text NOT NULL,
  commitment_text_1 text NOT NULL,
  commitment_text_2 text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT about_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.about_values (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  icon text,
  title text NOT NULL,
  description text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT about_values_pkey PRIMARY KEY (id)
);
CREATE TABLE public.access_config (
  id SERIAL,
  config_key text NOT NULL UNIQUE,
  config_value text NOT NULL,
  description text,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT access_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admission_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  target_date timestamp with time zone NOT NULL,
  countdown_message text NOT NULL,
  header_title text NOT NULL,
  header_subtitle text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admission_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admission_contact (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  address text NOT NULL,
  phone_label text NOT NULL,
  phone_value text NOT NULL,
  email_label text NOT NULL,
  email_value text NOT NULL,
  website_label text NOT NULL,
  website_value text NOT NULL,
  schedule text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admission_contact_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admission_dates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  date_range text NOT NULL,
  subtitle text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admission_dates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admission_requirements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  requirement text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admission_requirements_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admission_specialties (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  emoji text NOT NULL,
  name text NOT NULL,
  description text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admission_specialties_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ai_models (
  id BIGSERIAL,
  provider text NOT NULL CHECK (provider = ANY (ARRAY['groq'::text, 'gemini'::text])),
  name text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  order_index integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ai_models_pkey PRIMARY KEY (id)
);
CREATE TABLE public.alumnos_profiles (
  id uuid NOT NULL,
  nombre_completo text,
  matricula text UNIQUE,
  carrera text,
  semestre integer,
  grupo text,
  avatar_url text,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT alumnos_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT alumnos_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.avisos_alumnos (
  id BIGSERIAL,
  titulo text NOT NULL,
  contenido text,
  importancia text DEFAULT 'normal'::text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT avisos_alumnos_pkey PRIMARY KEY (id)
);
CREATE TABLE public.baetam_advantages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT baetam_advantages_pkey PRIMARY KEY (id)
);
CREATE TABLE public.baetam_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  hero_image_url text NOT NULL,
  title text NOT NULL,
  subtitle text NOT NULL,
  target_date timestamp with time zone NOT NULL,
  countdown_label text NOT NULL,
  countdown_date_text text NOT NULL,
  inscriptions_title text NOT NULL,
  inscriptions_period_title text NOT NULL,
  inscriptions_period_description text NOT NULL,
  requirements_title text NOT NULL,
  advantages_title text NOT NULL,
  contact_title text NOT NULL,
  contact_description text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT baetam_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.baetam_contact_lines (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  line_text text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT baetam_contact_lines_pkey PRIMARY KEY (id)
);
CREATE TABLE public.baetam_info_cards (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT baetam_info_cards_pkey PRIMARY KEY (id)
);
CREATE TABLE public.baetam_requirements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  icon text NOT NULL,
  text text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT baetam_requirements_pkey PRIMARY KEY (id)
);
CREATE TABLE public.calificaciones (
  id BIGSERIAL,
  alumno_id uuid,
  materia text NOT NULL,
  semestre integer NOT NULL,
  parcial1 numeric,
  parcial2 numeric,
  parcial3 numeric,
  promedio_final numeric GENERATED ALWAYS AS (
    ((COALESCE(parcial1, 0) + COALESCE(parcial2, 0) + COALESCE(parcial3, 0)) / 
    (NULLIF((
      CASE WHEN parcial1 IS NOT NULL THEN 1 ELSE 0 END + 
      CASE WHEN parcial2 IS NOT NULL THEN 1 ELSE 0 END + 
      CASE WHEN parcial3 IS NOT NULL THEN 1 ELSE 0 END
    ), 0))::numeric)
  ) STORED,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  tipo_materia text DEFAULT 'basica'::text CHECK (tipo_materia = ANY (ARRAY['basica'::text, 'especialidad'::text])),
  CONSTRAINT calificaciones_pkey PRIMARY KEY (id),
  CONSTRAINT calificaciones_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.carreras_tecnicas (
  id BIGSERIAL,
  nombre text NOT NULL,
  descripcion text,
  imagen_url text NOT NULL,
  programa_competencia text,
  justificacion text,
  perfil_egreso text,
  area_especializacion text,
  habilidades_socioemocionales text,
  oportunidades_profesionales text,
  plan_estudios_url text,
  pdf_start_page integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT carreras_tecnicas_pkey PRIMARY KEY (id)
);
CREATE TABLE public.chatbot_config (
  id BIGSERIAL,
  provider text NOT NULL DEFAULT 'groq'::text CHECK (provider = ANY (ARRAY['groq'::text, 'gemini'::text])),
  base_url text,
  api_key text,
  model text,
  system_prompt text,
  enable_db_context boolean NOT NULL DEFAULT true,
  enabled boolean NOT NULL DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  groq_api_key text,
  gemini_api_key text,
  fallback_enabled boolean NOT NULL DEFAULT false,
  primary_provider text DEFAULT 'groq'::text,
  CONSTRAINT chatbot_config_pkey PRIMARY KEY (id),
  CONSTRAINT chatbot_config_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.chatbot_questions (
  id BIGSERIAL,
  question_text text NOT NULL,
  source_page text,
  conversation_id text,
  user_agent text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT chatbot_questions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.clubs (
  id BIGSERIAL,
  nombre text NOT NULL,
  categoria text NOT NULL CHECK (categoria = ANY (ARRAY['Deportivo'::text, 'Cultural'::text, 'Academico'::text])),
  descripcion text,
  beneficios text,
  foto_url text,
  icono text,
  link text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  color text DEFAULT '#4a90e2'::text,
  CONSTRAINT clubs_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contact_cta (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  highlight_text text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contact_cta_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contact_directory (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  icon text,
  title text NOT NULL,
  detail text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contact_directory_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contact_faq (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  question text NOT NULL,
  answer text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contact_faq_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contact_location (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  address_text text NOT NULL,
  map_embed_url text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contact_location_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contact_main (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  address_line1 text NOT NULL,
  address_line2 text NOT NULL,
  address_line3 text,
  phone text NOT NULL,
  email text NOT NULL,
  website text NOT NULL,
  rating_text text NOT NULL,
  status_text text NOT NULL,
  hours_line1 text NOT NULL,
  hours_line2 text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contact_main_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contact_social (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  icon text,
  name text NOT NULL,
  url text NOT NULL,
  description text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contact_social_pkey PRIMARY KEY (id)
);
CREATE TABLE public.credits_authors (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  career text NOT NULL,
  description text,
  photo_url text,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT credits_authors_pkey PRIMARY KEY (id)
);
CREATE TABLE public.credits_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  subtitle text NOT NULL,
  license_title text,
  license_text text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT credits_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.edupanel_allowed_accounts (
  id SERIAL,
  email text NOT NULL UNIQUE,
  is_master boolean DEFAULT false,
  added_by text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT edupanel_allowed_accounts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.gallery_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  section text NOT NULL,
  title text NOT NULL,
  description text,
  image_url text NOT NULL,
  is_locked boolean NOT NULL DEFAULT false,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT gallery_items_pkey PRIMARY KEY (id)
);
CREATE TABLE public.hero_slides (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  image_url text NOT NULL,
  is_locked boolean NOT NULL DEFAULT false,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT hero_slides_pkey PRIMARY KEY (id)
);
CREATE TABLE public.home_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  image_url text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  path text NOT NULL,
  is_locked boolean NOT NULL DEFAULT false,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT home_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.preregistro_config (
  id integer NOT NULL DEFAULT 1 CHECK (id = 1),
  habilitado boolean DEFAULT true,
  titulo_header text DEFAULT '¡Tu futuro comienza en el CBTa 134!'::text,
  subtitulo_header text DEFAULT 'Realiza tu pre-registro en línea de forma rápida y segura.'::text,
  fecha_cierre timestamp with time zone DEFAULT '2025-05-01 00:00:00+00'::timestamp with time zone,
  mensaje_cierre text DEFAULT 'Cierre de convocatoria en:'::text,
  indicaciones_ficha text DEFAULT 'Acude con tu ficha impresa en las fechas indicadas.'::text,
  requisitos_json jsonb DEFAULT '[{"txt": "CURP del aspirante", "icon": "🪪"}, {"txt": "Correo electrónico Gmail", "icon": "📧"}]'::jsonb,
  pasos_json jsonb DEFAULT '[{"num": "01", "desc": "Ingresa tus datos personales.", "titulo": "Llena el formulario"}, {"num": "02", "desc": "Obtén tu PDF.", "titulo": "Descarga tu ficha"}]'::jsonb,
  updated_at timestamp with time zone DEFAULT now(),
  badge_texto text DEFAULT '📋 Convocatoria Abierta · Ciclo 2025–2026'::text,
  cta_texto text DEFAULT '¡Pre-Regístrate Ahora!'::text,
  cta_subtexto text DEFAULT 'Es rápido, gratuito y 100% en línea'::text,
  card_titulo text DEFAULT 'Pre-Regístrate'::text,
  card_descripcion text DEFAULT 'Completa el formulario de pre-registro para aspirantes de nuevo ingreso. Al terminar recibirás tu ficha oficial en PDF lista para imprimir.'::text,
  card_checklist_json jsonb DEFAULT '["Datos personales y de contacto", "Elección de carrera técnica", "Datos de escuela de procedencia", "Información del padre, madre o tutor", "Ficha PDF descargable al instante"]'::jsonb,
  card_boton_texto text DEFAULT 'Iniciar Pre-Registro →'::text,
  pasos_titulo text DEFAULT '¿Cómo funciona?'::text,
  pasos_subtitulo text DEFAULT 'Sigue estos sencillos pasos para completar tu pre-registro'::text,
  carreras_titulo text DEFAULT 'Carreras Técnicas Disponibles'::text,
  carreras_subtitulo text DEFAULT 'Elige la que mejor se adapte a tus intereses y vocación'::text,
  requisitos_titulo text DEFAULT '¿Qué necesitas para pre-registrarte?'::text,
  requisitos_subtitulo text DEFAULT 'Ten a la mano la siguiente información antes de iniciar'::text,
  cta_final_titulo text DEFAULT '¿Listo para unirte al CBTa 134?'::text,
  cta_final_subtitulo text DEFAULT 'El proceso tarda menos de 10 minutos. ¡Hazlo ahora!'::text,
  cta_final_boton text DEFAULT 'Comenzar Pre-Registro'::text,
  cta_final_boton_sub text DEFAULT 'Formulario en línea · Ficha PDF inmediata'::text,
  cerrada_badge text DEFAULT '🚫 Convocatoria Cerrada'::text,
  cerrada_titulo text DEFAULT 'El proceso de pre-registro ha finalizado'::text,
  cerrada_mensaje text DEFAULT 'Gracias por tu interés en el CBTa 134. Mantente pendiente de nuestras redes sociales para próximas convocatorias.'::text,
  form_badge text DEFAULT 'Nuevo Ingreso 2025–2026'::text,
  form_titulo text DEFAULT 'Pre-Registro de Aspirantes'::text,
  form_subtitulo text DEFAULT 'Completa tu pre-registro para obtener tu ficha de inscripción. Es rápido y seguro.'::text,
  home_badge text DEFAULT 'NUEVO INGRESO 2025'::text,
  home_titulo text DEFAULT '¡Pre-Regístrate Hoy!'::text,
  home_descripcion text DEFAULT 'Inicia tu proceso de admisión para el próximo ciclo escolar. Obtén tu ficha oficial de manera fácil y rápida.'::text,
  home_boton text DEFAULT 'Ir al Pre-Registro →'::text,
  home_icono text DEFAULT '📝'::text,
  form_titulo_paso1 text DEFAULT '👤 Datos del Aspirante'::text,
  form_titulo_paso2 text DEFAULT '🎓 Carrera Técnica'::text,
  form_desc_paso2 text DEFAULT 'Selecciona la carrera técnica de tu preferencia.'::text,
  form_titulo_paso3 text DEFAULT '🏫 Escuela de Procedencia'::text,
  form_desc_paso3 text DEFAULT 'Proporciona los datos de la secundaria de la que egresaste.'::text,
  form_titulo_paso4 text DEFAULT '👨‍👩‍👦 Datos del Tutor / Padre o Madre'::text,
  form_desc_paso4 text DEFAULT 'Proporciona los datos de la persona responsable del aspirante.'::text,
  form_titulo_paso5 text DEFAULT '✅ Confirmación de Datos'::text,
  form_desc_paso5 text DEFAULT 'Revisa que todos tus datos sean correctos antes de enviar.'::text,
  exito_icono text DEFAULT '🎉'::text,
  exito_titulo text DEFAULT '¡Pre-Registro Exitoso!'::text,
  exito_mensaje text DEFAULT 'Tu pre-registro ha sido recibido. Guarda tu folio y descarga tu ficha.'::text,
  exito_btn_pdf text DEFAULT '📄 Descargar Ficha PDF'::text,
  exito_btn_inicio text DEFAULT 'Ir al Inicio'::text,
  stepper_json jsonb DEFAULT '[{"id": 1, "icon": "👤", "label": "Datos Personales"}, {"id": 2, "icon": "🎓", "label": "Carrera"}, {"id": 3, "icon": "🏫", "label": "Escuela Origen"}, {"id": 4, "icon": "👨‍👩‍👦", "label": "Datos del Tutor"}, {"id": 5, "icon": "✅", "label": "Confirmación"}]'::jsonb,
  CONSTRAINT preregistro_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.preregistros (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  folio text NOT NULL UNIQUE,
  nombre text NOT NULL,
  apellido_paterno text NOT NULL,
  apellido_materno text NOT NULL,
  curp text NOT NULL,
  sexo text NOT NULL CHECK (sexo = ANY (ARRAY['Masculino'::text, 'Femenino'::text, 'Otro'::text])),
  fecha_nacimiento date NOT NULL,
  correo text NOT NULL,
  estado_civil text NOT NULL CHECK (estado_civil = ANY (ARRAY['Soltero/a'::text, 'Casado/a'::text, 'Otro'::text])),
  telefono text NOT NULL,
  lugar_nacimiento text NOT NULL,
  domicilio text NOT NULL,
  colonia text NOT NULL,
  municipio text NOT NULL,
  codigo_postal text NOT NULL,
  carrera_id bigint,
  carrera_nombre text NOT NULL,
  escuela_tipo text NOT NULL CHECK (escuela_tipo = ANY (ARRAY['Pública'::text, 'Privada'::text, 'Indígena'::text, 'Comunitaria'::text])),
  escuela_nombre text NOT NULL,
  escuela_municipio text NOT NULL,
  promedio_general numeric NOT NULL CHECK (promedio_general >= 0::numeric AND promedio_general <= 10::numeric),
  tutor_nombre text NOT NULL,
  tutor_ocupacion text NOT NULL,
  tutor_curp text NOT NULL,
  tutor_grado_estudios text NOT NULL,
  tutor_telefono text NOT NULL,
  tutor_parentesco text NOT NULL CHECK (tutor_parentesco = ANY (ARRAY['Padre'::text, 'Madre'::text, 'Tutor/a'::text, 'Otro'::text])),
  estado_registro text DEFAULT 'Pendiente'::text CHECK (estado_registro = ANY (ARRAY['Pendiente'::text, 'Revisión'::text, 'Aceptado'::text, 'Rechazado'::text])),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT preregistros_pkey PRIMARY KEY (id),
  CONSTRAINT preregistros_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras_tecnicas(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  nombre text,
  apellidos text,
  curp text UNIQUE,
  matricula text UNIQUE,
  grado integer,
  grupo text,
  rol text DEFAULT 'alumno'::text,
  avatar_url text,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  numero_control character varying CHECK (length(numero_control::text) = 14),
  carrera_id bigint,
  email text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.publicaciones_globales (
  id BIGSERIAL,
  autor_id uuid,
  titulo text NOT NULL,
  contenido text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  media_url text,
  media_type text,
  CONSTRAINT publicaciones_globales_pkey PRIMARY KEY (id),
  CONSTRAINT publicaciones_globales_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES auth.users(id)
);
CREATE TABLE public.storage_usage_cache (
  id integer NOT NULL DEFAULT 1 CHECK (id = 1),
  db_bytes bigint DEFAULT 0,
  storage_bytes bigint DEFAULT 0,
  buckets jsonb DEFAULT '[]'::jsonb,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT storage_usage_cache_pkey PRIMARY KEY (id)
);
CREATE TABLE public.teachers_config (
  id BIGSERIAL,
  title text,
  subtitle text,
  hero_image_url text,
  cta_label text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT teachers_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.teachers_links (
  id BIGSERIAL,
  name text NOT NULL,
  description text,
  icon text,
  url text NOT NULL,
  color text,
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT teachers_links_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ui_footer_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  school_name text NOT NULL,
  location_text text NOT NULL,
  tagline_text text NOT NULL,
  copyright_text text NOT NULL,
  rights_text text NOT NULL,
  legal_text_1 text NOT NULL,
  legal_text_2 text NOT NULL,
  legal_text_3 text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ui_footer_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ui_footer_links (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  label text NOT NULL,
  href text NOT NULL,
  icon_url text,
  style_class text,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ui_footer_links_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ui_header_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  logo_url text NOT NULL,
  title_text text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ui_header_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ui_header_links (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  label text NOT NULL,
  href text,
  path text NOT NULL,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ui_header_links_pkey PRIMARY KEY (id)
);