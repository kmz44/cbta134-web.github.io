import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import '../styles/PreRegistroLanding.css';

import { supabase } from '../lib/supabaseClient';

// Helper: asigna emoji según el nombre de la carrera
function getCarreraEmoji(nombre = '') {
    const n = nombre.toLowerCase();
    if (n.includes('contab') || n.includes('admin')) return '💼';
    if (n.includes('ofimátic') || n.includes('ofimatica')) return '💻';
    if (n.includes('program') || n.includes('software') || n.includes('informátic')) return '⌨️';
    if (n.includes('agropecuari') || n.includes('agríco') || n.includes('agricol')) return '🌾';
    if (n.includes('pecuari') || n.includes('ganader')) return '🐄';
    if (n.includes('aliment')) return '🍽️';
    if (n.includes('electr')) return '⚡';
    if (n.includes('mecán') || n.includes('mecan') || n.includes('industrial')) return '🔧';
    return '📚';
}

export default function PreRegistroLanding() {
    const navigate = useNavigate();
    const [contador, setContador] = useState({ dias: 0, horas: 0, minutos: 0, segundos: 0 });
    const [config, setConfig] = useState(null);
    const [loading, setLoading] = useState(true);
    const [carreras, setCarreras] = useState([]);
    const [admissionDates, setAdmissionDates] = useState([]);
    const [requirements, setRequirements] = useState([]);
    const [contact, setContact] = useState(null);
    const [location, setLocation] = useState(null);

    useEffect(() => {
        const fetchConfig = async () => {
            try {
                const { data, error } = await supabase
                    .from('preregistro_config')
                    .select('*')
                    .eq('id', 1)
                    .single();

                if (data) setConfig(data);
            } catch (err) {
                console.error('Error fetching preregistro config:', err);
            } finally {
                setLoading(false);
            }
        };

        const fetchCarreras = async () => {
            try {
                const { data, error } = await supabase
                    .from('carreras_tecnicas')
                    .select('id, nombre, descripcion, imagen_url');
                if (data && data.length > 0) {
                    setCarreras(data.map(c => ({
                        ...c,
                        // Generar un emoji basado en el nombre si no hay imagen
                        icono: getCarreraEmoji(c.nombre),
                        descripcion_corta: c.descripcion ? c.descripcion.substring(0, 120) + (c.descripcion.length > 120 ? '...' : '') : c.nombre,
                    })));
                } else {
                    setCarreras([
                        { icono: '💼', nombre: 'Técnico en Contabilidad', descripcion_corta: 'Finanzas, contabilidad y administración.' },
                        { icono: '💻', nombre: 'Técnico en Ofimática', descripcion_corta: 'Herramientas digitales y productividad.' },
                        { icono: '⌨️', nombre: 'Técnico en Programación', descripcion_corta: 'Desarrollo de software y apps.' },
                        { icono: '🌾', nombre: 'Técnico Agropecuario', descripcion_corta: 'Producción agrícola sustentable.' },
                        { icono: '🐄', nombre: 'Técnico en Sistemas de Prod. Pecuaria', descripcion_corta: 'Ganadería y producción animal.' },
                    ]);
                }
            } catch (err) {
                console.error('Error fetching carreras:', err);
            }
        };

        const fetchAdmissionData = async () => {
            try {
                const { data: dates } = await supabase.from('admission_dates').select('*').order('order_index', { ascending: true });
                const { data: reqs } = await supabase.from('admission_requirements').select('*').order('order_index', { ascending: true });
                const { data: cont } = await supabase.from('admission_contact').select('*').order('created_at', { ascending: false }).limit(1).single();
                const { data: loc } = await supabase.from('contact_location').select('*').order('created_at', { ascending: false }).limit(1).single();

                if (dates) setAdmissionDates(dates);
                if (reqs) setRequirements(reqs);
                if (cont) setContact(cont);
                if (loc) setLocation(loc);
            } catch (err) {
                console.error('Error fetching admission data:', err);
            }
        };

        fetchConfig();
        fetchCarreras();
        fetchAdmissionData();
    }, []);

    useEffect(() => {
        if (!config?.fecha_cierre) return;
        const objetivo = new Date(config.fecha_cierre);
        const tick = () => {
            const diff = objetivo - new Date();
            if (diff > 0) {
                setContador({
                    dias: Math.floor(diff / 86400000),
                    horas: Math.floor((diff % 86400000) / 3600000),
                    minutos: Math.floor((diff % 3600000) / 60000),
                    segundos: Math.floor((diff % 60000) / 1000),
                });
            } else {
                setContador({ dias: 0, horas: 0, minutos: 0, segundos: 0 });
            }
        };
        tick();
        const t = setInterval(tick, 1000);
        return () => clearInterval(t);
    }, [config]);

    const irAlFormulario = () => navigate('/preregistro/formulario');

    if (loading) return <div className="prl-page"><div className="prl-section-header"><h2>Cargando...</h2></div></div>;

    // ─── CONVOCATORIA CERRADA ────────────────────────────────
    if (config && !config.habilitado) {
        return (
            <div className="prl-page">
                <section className="prl-hero">
                    <div className="prl-hero__bg" aria-hidden="true" />
                    <div className="prl-hero__content">
                        <span className="prl-badge prl-badge--closed">{config?.cerrada_badge || '🚫 Convocatoria Cerrada'}</span>
                        <h1 className="prl-hero__title" dangerouslySetInnerHTML={{ __html: (config?.cerrada_titulo || 'El proceso de pre-registro ha finalizado').replace(/\n/g, '<br />') }} />
                        <p className="prl-hero__sub">{config?.cerrada_mensaje || 'Gracias por tu interés en el CBTa 134. Mantente pendiente de nuestras redes sociales para próximas convocatorias.'}</p>
                        <button className="prl-cta" onClick={() => navigate('/')}>Regresar al Inicio</button>
                    </div>
                </section>
            </div>
        );
    }

    // ─── VALORES CON FALLBACKS ──────────────────────────────
    const c = config || {};
    const badgeTexto = c.badge_texto || '📋 Convocatoria Abierta · Ciclo 2025–2026';
    const tituloHeader = c.titulo_header || '¡Tu futuro comienza en el CBTa 134!';
    const subtituloHeader = c.subtitulo_header || 'Realiza tu pre-registro en línea de forma rápida y segura.';
    const ctaTexto = c.cta_texto || '¡Pre-Regístrate Ahora!';
    const ctaSubtexto = c.cta_subtexto || 'Es rápido, gratuito y 100% en línea';
    const mensajeCierre = c.mensaje_cierre || 'Cierre de convocatoria en:';

    const cardTitulo = c.card_titulo || 'Pre-Regístrate';
    const cardDescripcion = c.card_descripcion || 'Completa el formulario de pre-registro para aspirantes de nuevo ingreso. Al terminar recibirás tu ficha oficial en PDF lista para imprimir.';
    const cardChecklist = Array.isArray(c.card_checklist_json) && c.card_checklist_json.length > 0
        ? c.card_checklist_json
        : ['Datos personales y de contacto', 'Elección de carrera técnica', 'Datos de escuela de procedencia', 'Información del padre, madre o tutor', 'Ficha PDF descargable al instante'];
    const cardBotonTexto = c.card_boton_texto || 'Iniciar Pre-Registro →';

    const pasosTitulo = c.pasos_titulo || '¿Cómo funciona?';
    const pasosSubtitulo = c.pasos_subtitulo || 'Sigue estos sencillos pasos para completar tu pre-registro';
    const pasos = Array.isArray(c.pasos_json) && c.pasos_json.length > 0
        ? c.pasos_json
        : [
            { num: '01', titulo: 'Llena el formulario', desc: 'Ingresa tus datos personales, carrera y escuela de procedencia.' },
            { num: '02', titulo: 'Selecciona tu carrera', desc: 'Elige la especialidad técnica que más te interese.' },
            { num: '03', titulo: 'Descarga tu ficha', desc: 'Obtén tu ficha oficial en PDF con tu folio único.' },
            { num: '04', titulo: 'Preséntate al plantel', desc: 'Acude con tu ficha impresa en las fechas indicadas.' }
        ];

    const carrerasTitulo = c.carreras_titulo || 'Carreras Técnicas Disponibles';
    const carrerasSubtitulo = c.carreras_subtitulo || 'Elige la que mejor se adapte a tus intereses y vocación';

    const requisitosTitulo = c.requisitos_titulo || '¿Qué necesitas para pre-registrarte?';
    const requisitosSubtitulo = c.requisitos_subtitulo || 'Ten a la mano la siguiente información antes de iniciar';
    const requisitos = Array.isArray(c.requisitos_json) && c.requisitos_json.length > 0
        ? c.requisitos_json
        : [
            { icon: '🪪', txt: 'CURP del aspirante' },
            { icon: '📅', txt: 'Fecha de nacimiento' },
            { icon: '📧', txt: 'Correo electrónico (Gmail)' },
            { icon: '📞', txt: 'Teléfono de contacto (10 dígitos)' },
            { icon: '🏫', txt: 'Datos de escuela de procedencia' },
            { icon: '👨‍👩‍👦', txt: 'CURP y datos del padre, madre o tutor' },
        ];

    const ctaFinalTitulo = c.cta_final_titulo || '¿Listo para unirte al CBTa 134?';
    const ctaFinalSubtitulo = c.cta_final_subtitulo || 'El proceso tarda menos de 10 minutos. ¡Hazlo ahora!';
    const ctaFinalBoton = c.cta_final_boton || 'Comenzar Pre-Registro';
    const ctaFinalBotonSub = c.cta_final_boton_sub || 'Formulario en línea · Ficha PDF inmediata';

    return (
        <div className="prl-page">

            {/* ── HERO ──────────────────────────────────── */}
            <section className="prl-hero">
                <div className="prl-hero__bg" aria-hidden="true" />
                <div className="prl-hero__particles" aria-hidden="true">
                    {[...Array(12)].map((_, i) => <span key={i} className="prl-particle" />)}
                </div>

                <div className="prl-hero__content">
                    <span className="prl-badge">{badgeTexto}</span>
                    <h1 className="prl-hero__title" dangerouslySetInnerHTML={{ __html: tituloHeader.replace(/\n/g, '<br />') }} />
                    <p className="prl-hero__sub">{subtituloHeader}</p>

                    <button id="btn-preregistrate" className="prl-cta" onClick={irAlFormulario}>
                        <span className="prl-cta__icon">📝</span>
                        <span className="prl-cta__text">
                            <strong>{ctaTexto}</strong>
                            <small>{ctaSubtexto}</small>
                        </span>
                        <span className="prl-cta__arrow">→</span>
                    </button>

                    <div className="prl-countdown">
                        <p className="prl-countdown__label">{mensajeCierre}</p>
                        <div className="prl-countdown__grid">
                            {[
                                { val: contador.dias, lbl: 'Días' },
                                { val: contador.horas, lbl: 'Horas' },
                                { val: contador.minutos, lbl: 'Min' },
                                { val: contador.segundos, lbl: 'Seg' },
                            ].map((u) => (
                                <div key={u.lbl} className="prl-countdown__unit">
                                    <span className="prl-countdown__num">{String(u.val).padStart(2, '0')}</span>
                                    <span className="prl-countdown__lbl">{u.lbl}</span>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </section>

            {/* ── TARJETA PRINCIPAL ────────────────────── */}
            <section className="prl-main-card-section">
                <div className="prl-main-card">
                    <div className="prl-main-card__left">
                        <div className="prl-main-card__icon-wrap">
                            <span className="prl-main-card__big-icon">🎓</span>
                        </div>
                        <h2 className="prl-main-card__title">{cardTitulo}</h2>
                        <p className="prl-main-card__desc" dangerouslySetInnerHTML={{ __html: cardDescripcion }} />
                        <ul className="prl-main-card__list">
                            {cardChecklist.map((item, i) => (
                                <li key={i}>✅ {item}</li>
                            ))}
                        </ul>
                        <button className="prl-main-card__btn" onClick={irAlFormulario}>
                            {cardBotonTexto}
                        </button>
                    </div>
                    <div className="prl-main-card__right">
                        <div className="prl-ficha-preview">
                            <div className="prl-ficha-preview__header">
                                <div className="prl-ficha-preview__logo">CBTa<br />134</div>
                                <div>
                                    <div className="prl-ficha-preview__school">CBTA No. 134</div>
                                    <div className="prl-ficha-preview__subtitle">Ficha de Pre-Registro</div>
                                </div>
                            </div>
                            <div className="prl-ficha-preview__folio">Folio: PRE-2025-0001</div>
                            {['Nombre', 'CURP', 'Carrera', 'Escuela origen', 'Tutor'].map((f) => (
                                <div key={f} className="prl-ficha-preview__row">
                                    <span>{f}:</span>
                                    <span className="prl-ficha-preview__bar" />
                                </div>
                            ))}
                            <div className="prl-ficha-preview__sello">🏫 CBTa 134</div>
                        </div>
                    </div>
                </div>
            </section>

            {/* ── PASOS ─────────────────────────────────── */}
            <section className="prl-steps">
                <div className="prl-section-header">
                    <h2>{pasosTitulo}</h2>
                    <p>{pasosSubtitulo}</p>
                </div>
                <div className="prl-steps__grid">
                    {pasos.map((p) => (
                        <div key={p.num} className="prl-step-card">
                            <div className="prl-step-card__num">{p.num}</div>
                            <h3 className="prl-step-card__title">{p.titulo}</h3>
                            <p className="prl-step-card__desc">{p.desc}</p>
                        </div>
                    ))}
                </div>
            </section>

            {/* ── CARRERAS ─────────────────────────────── */}
            <section className="prl-carreras">
                <div className="prl-section-header">
                    <h2>{carrerasTitulo}</h2>
                    <p>{carrerasSubtitulo}</p>
                </div>
                <div className="prl-carreras__grid">
                    {carreras.map((c) => (
                        <div key={c.nombre} className="prl-carrera-card">
                            <span className="prl-carrera-card__icon">{c.icono || '📚'}</span>
                            <h3 className="prl-carrera-card__name">{c.nombre}</h3>
                            <p className="prl-carrera-card__desc">{c.descripcion_corta}</p>
                        </div>
                    ))}
                </div>
            </section>

            {/* ── REQUISITOS ───────────────────────────── */}
            <section className="prl-requisitos">
                <div className="prl-section-header prl-section-header--light">
                    <h2>{requisitosTitulo}</h2>
                    <p>{requisitosSubtitulo}</p>
                </div>
                <div className="prl-req-grid">
                    {requirements.length > 0 ? (
                        requirements.map((r) => (
                            <div key={r.id} className="prl-req-item">
                                <span className="prl-req-item__icon">🔹</span>
                                <span>{r.requirement}</span>
                            </div>
                        ))
                    ) : (
                        requisitos.map((r, i) => (
                            <div key={i} className="prl-req-item">
                                <span className="prl-req-item__icon">{r.icon}</span>
                                <span>{r.txt}</span>
                            </div>
                        ))
                    )}
                </div>
            </section>

            {/* ── FECHAS / PROCESO DE ADMISIÓN ───────────── */}
            <section className="prl-steps" style={{ background: 'var(--bg-secondary)', marginTop: '0' }}>
                <div className="prl-section-header">
                    <h2>📅 Fechas del Proceso de Admisión</h2>
                    <p>Calendario oficial para aspirantes ciclo 2026</p>
                </div>
                <div className="prl-steps__grid">
                    {admissionDates.map((item, idx) => (
                        <div key={item.id} className="prl-step-card" style={{ borderTop: '4px solid #1877f2' }}>
                            <div className="prl-step-card__num">{idx + 1}</div>
                            <h3 className="prl-step-card__title">{item.title}</h3>
                            <p className="prl-step-card__desc" style={{ fontWeight: 'bold', color: '#1877f2' }}>{item.date_range}</p>
                            <p className="prl-step-card__desc">{item.subtitle}</p>
                        </div>
                    ))}
                </div>
            </section>

            {/* ── UBICACIÓN / MAPA ───────────────────────── */}
            <section className="prl-carreras" style={{ background: '#fff' }}>
                <div className="prl-section-header">
                    <h2>📍 Nuestra Ubicación</h2>
                    <p>{location?.address_text || contact?.address || 'Calle Josefa Ortiz de Domínguez, Colonia Jesús Xolalpan, San Francisco Tetlanohcan, Tlaxcala'}</p>
                </div>
                <div className="prl-map-container" style={{
                    borderRadius: '24px',
                    overflow: 'hidden',
                    boxShadow: '0 10px 30px rgba(0,0,0,0.1)',
                    maxWidth: '1100px',
                    margin: '0 auto',
                    border: '1px solid #eee'
                }}>
                    <iframe
                        src={location?.map_embed_url || "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3766.47644265494!2d-98.140814!3d19.261733!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x85cfdd8ebaaaaaab%3A0x27dafbca82bfb2a0!2sCentro%20De%20Bachillerato%20Tecnol%C3%B3gico%20Agropecuario%20N%C3%BAm.%20134!5e0!3m2!1ses-419!2smx!4v1772321237884!5m2!1ses-419!2smx"}
                        width="100%"
                        height="450"
                        style={{ border: 0, display: 'block' }}
                        allowFullScreen=""
                        loading="lazy"
                        referrerPolicy="no-referrer-when-downgrade"
                    ></iframe>
                </div>

                <div style={{ textAlign: 'center', marginTop: '30px' }}>
                    <p style={{ color: '#666' }}>
                        📞 {contact?.phone_value || '246 467 4237'} | 📧 {contact?.email_value || 'cbta134@yahoo.com.mx'}
                    </p>
                </div>
            </section>

            {/* ── CTA FINAL ─────────────────────────────── */}
            <section className="prl-cta-final">
                <h2>{ctaFinalTitulo}</h2>
                <p>{ctaFinalSubtitulo}</p>
                <button className="prl-cta prl-cta--lg" onClick={irAlFormulario}>
                    <span className="prl-cta__icon">📝</span>
                    <span className="prl-cta__text">
                        <strong>{ctaFinalBoton}</strong>
                        <small>{ctaFinalBotonSub}</small>
                    </span>
                    <span className="prl-cta__arrow">→</span>
                </button>
            </section>
        </div>
    );
}
