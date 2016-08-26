--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: anonymous_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE anonymous_contacts (
    id integer NOT NULL,
    type character varying(255),
    what_doing text,
    what_wrong text,
    details text,
    source character varying(255),
    page_owner character varying(255),
    user_agent text,
    referrer character varying(2048),
    javascript_enabled boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    personal_information_status character varying(255),
    slug character varying(255),
    service_satisfaction_rating integer,
    user_specified_url text,
    is_actionable boolean DEFAULT true NOT NULL,
    reason_why_not_actionable character varying(255),
    path character varying(2048) NOT NULL,
    content_item_id integer,
    marked_as_spam boolean DEFAULT false NOT NULL,
    reviewed boolean DEFAULT false NOT NULL
);


--
-- Name: anonymous_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE anonymous_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anonymous_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE anonymous_contacts_id_seq OWNED BY anonymous_contacts.id;


--
-- Name: archived_service_feedbacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE archived_service_feedbacks (
    id integer NOT NULL,
    type character varying,
    slug character varying,
    service_satisfaction_rating integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: archived_service_feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE archived_service_feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: archived_service_feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE archived_service_feedbacks_id_seq OWNED BY archived_service_feedbacks.id;


--
-- Name: content_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_items (
    id integer NOT NULL,
    path character varying(2048) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_items_id_seq OWNED BY content_items.id;


--
-- Name: content_items_organisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_items_organisations (
    content_item_id integer,
    organisation_id integer
);


--
-- Name: feedback_export_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feedback_export_requests (
    id integer NOT NULL,
    notification_email character varying(255),
    filename character varying(255),
    generated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    filters text
);


--
-- Name: feedback_export_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feedback_export_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedback_export_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feedback_export_requests_id_seq OWNED BY feedback_export_requests.id;


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organisations (
    id integer NOT NULL,
    slug character varying(255) NOT NULL,
    web_url character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    acronym character varying(255),
    govuk_status character varying(255),
    content_id character varying(255) NOT NULL
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organisations_id_seq OWNED BY organisations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY anonymous_contacts ALTER COLUMN id SET DEFAULT nextval('anonymous_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY archived_service_feedbacks ALTER COLUMN id SET DEFAULT nextval('archived_service_feedbacks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_items ALTER COLUMN id SET DEFAULT nextval('content_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feedback_export_requests ALTER COLUMN id SET DEFAULT nextval('feedback_export_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisations ALTER COLUMN id SET DEFAULT nextval('organisations_id_seq'::regclass);


--
-- Name: anonymous_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY anonymous_contacts
    ADD CONSTRAINT anonymous_contacts_pkey PRIMARY KEY (id);


--
-- Name: archived_service_feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY archived_service_feedbacks
    ADD CONSTRAINT archived_service_feedbacks_pkey PRIMARY KEY (id);


--
-- Name: content_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_items
    ADD CONSTRAINT content_items_pkey PRIMARY KEY (id);


--
-- Name: feedback_export_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feedback_export_requests
    ADD CONSTRAINT feedback_export_requests_pkey PRIMARY KEY (id);


--
-- Name: organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: index_anonymous_contacts_on_content_item_id_and_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_anonymous_contacts_on_content_item_id_and_created_at ON anonymous_contacts USING btree (content_item_id, created_at);


--
-- Name: index_anonymous_contacts_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_anonymous_contacts_on_created_at ON anonymous_contacts USING btree (created_at);


--
-- Name: index_anonymous_contacts_on_created_at_and_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_anonymous_contacts_on_created_at_and_path ON anonymous_contacts USING btree (created_at DESC, path varchar_pattern_ops);


--
-- Name: index_anonymous_contacts_on_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_anonymous_contacts_on_path ON anonymous_contacts USING btree (path varchar_pattern_ops);


--
-- Name: index_content_items_organisations_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_content_items_organisations_unique ON content_items_organisations USING btree (content_item_id, organisation_id);


--
-- Name: index_organisations_on_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organisations_on_content_id ON organisations USING btree (content_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140728110134');

INSERT INTO schema_migrations (version) VALUES ('20141002153042');

INSERT INTO schema_migrations (version) VALUES ('20141002165103');

INSERT INTO schema_migrations (version) VALUES ('20141230121133');

INSERT INTO schema_migrations (version) VALUES ('20150115215320');

INSERT INTO schema_migrations (version) VALUES ('20150313183713');

INSERT INTO schema_migrations (version) VALUES ('20150430133750');

INSERT INTO schema_migrations (version) VALUES ('20150505100000');

INSERT INTO schema_migrations (version) VALUES ('20150505162618');

INSERT INTO schema_migrations (version) VALUES ('20150513094727');

INSERT INTO schema_migrations (version) VALUES ('20150515222831');

INSERT INTO schema_migrations (version) VALUES ('20150518151221');

INSERT INTO schema_migrations (version) VALUES ('20150521102732');

INSERT INTO schema_migrations (version) VALUES ('20150521140644');

INSERT INTO schema_migrations (version) VALUES ('20150521144116');

INSERT INTO schema_migrations (version) VALUES ('20150522151256');

INSERT INTO schema_migrations (version) VALUES ('20150526095541');

INSERT INTO schema_migrations (version) VALUES ('20150604140707');

INSERT INTO schema_migrations (version) VALUES ('20150611133227');

INSERT INTO schema_migrations (version) VALUES ('20150612130729');

INSERT INTO schema_migrations (version) VALUES ('20150623151655');

INSERT INTO schema_migrations (version) VALUES ('20150915134640');

INSERT INTO schema_migrations (version) VALUES ('20151202212408');

INSERT INTO schema_migrations (version) VALUES ('20151203001139');

INSERT INTO schema_migrations (version) VALUES ('20160511164547');

INSERT INTO schema_migrations (version) VALUES ('20160822145924');

INSERT INTO schema_migrations (version) VALUES ('20160826105129');

