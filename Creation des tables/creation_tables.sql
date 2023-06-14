drop table if exists utilisateur,personne,association,groupe,concert_passe,
concert_futur,lieu,genre, morceau,playlist,avis,tag,
sous_genre,relation_amitie,relation_follow,relation_appartenance,
relation_groupe_concert_passe,relation_groupe_concert_futur,relation_utilisateur_concert_futur,
relation_utilisateur_concert_passe,relation_personne_interesse,
relation_personne_participe,relation_playlist_morceau,relation_morceau_genre,
avis_groupe,avis_lieu, avis_concert_futur,avis_morceau,avis_tag,groupe_tag,
concert_passe_tag,morceau_tag, lieu_tag  CASCADE;


--Entités de bases
create table utilisateur (
    id_utilisateur SERIAL PRIMARY KEY,
    adresse_mail VARCHAR(40) NOT NULL,
    mot_de_pase VARCHAR(40) NOT NULL,
    CHECK (adresse_mail LIKE '%@%.%')
    );

create table personne (
    id_personne SERIAL PRIMARY KEY,
    id_utilisateur INTEGER,
    nom VARCHAR(30) NOT NULL,
    prenom VARCHAR(30) NOT NULL,
    adresse VARCHAR(50) , /*On laisse la liberter de fournir ou non son adresse*/
    FOREIGN KEY(id_utilisateur) REFERENCES utilisateur (id_utilisateur)
);

create table association (
    id_asso SERIAL PRIMARY KEY,
    id_utilisateur INTEGER,
    denomination VARCHAR(30) NOT NULL,
    adresse VARCHAR(40)  NOT NULL, /*Une association doit obligatoirement fournir une adresse*/
    FOREIGN KEY(id_utilisateur) REFERENCES utilisateur (id_utilisateur)
);

create table groupe (
    id_groupe SERIAL PRIMARY KEY,
    nom_grp VARCHAR(30) NOT NULL
    );

create table lieu (
    id_lieu SERIAL PRIMARY KEY,
    nom_lieu VARCHAR(30) NOT NULL,
    pays VARCHAR(30) NOT NULL,
    ville VARCHAR(30) NOT NULL,
    adresse VARCHAR(40) NOT NULL,
    UNIQUE(nom_lieu,pays,ville,adresse)
    );

create table concert_passe (
    id_concert SERIAL PRIMARY KEY,
    date_debut timestamp NOT NULL,
    lieu INTEGER  ,
    prix INTEGER,
    nb_places_effective INTEGER,
    cause VARCHAR(255),
    lien_photos VARCHAR(255),
    lien_video VARCHAR(255),
    espace_exterieur BOOLEAN NOT NULL DEFAULT false,
    familiale BOOLEAN NOT NULL DEFAULT false,
    FOREIGN KEY (lieu) REFERENCES lieu(id_lieu),
    CHECK(nb_places_effective >0),
    CHECK (prix >= 0)
    );

  create table concert_futur (
    id_concert SERIAL PRIMARY KEY,
    date_concert timestamp NOT NULL,
    lieu INTEGER ,
    prix INTEGER,
    nb_places INTEGER,
    cause VARCHAR(255),
    espace_exterieur BOOLEAN NOT NULL DEFAULT false,
    familiale BOOLEAN NOT NULL DEFAULT false,
    besoin_volontaires BOOLEAN NOT NULL DEFAULT false,
    FOREIGN KEY(lieu)  REFERENCES lieu(id_lieu),
    CHECK(nb_places >0),
    CHECK (prix >= 0)
    );

create table genre (
    id_genre SERIAL PRIMARY KEY,
    nom_genre VARCHAR(30) NOT NULL
    );

create table morceau (
    id_morceau  SERIAL PRIMARY KEY,
    nom_morceau VARCHAR(30) ,
    groupe INTEGER,
    FOREIGN KEY (groupe) REFERENCES groupe(id_groupe)
    );

create table playlist (
    id_playlist SERIAL PRIMARY KEY,
    id_utilisateur INTEGER,
    nom_playlist VARCHAR(30) NOT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur (id_utilisateur)
    );

create table avis (
    id_avis SERIAL PRIMARY KEY,
    message_avis VARCHAR(255) ,
    note INTEGER NOT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur (id_utilisateur),
    CHECK (note >=0 AND note <=5)
    );

create table tag (
    id_tag SERIAL PRIMARY KEY,
    valeur VARCHAR(40) NOT NULL 
    );


-- Tables modelisant les relations entre les entités

--Relation de sous genre
create table sous_genre (
    id_sous_genre INTEGER ,
    id_genre_pere INTEGER,
    FOREIGN KEY (id_sous_genre)  REFERENCES genre(id_genre),
    FOREIGN KEY(id_genre_pere)  REFERENCES genre(id_genre),
    PRIMARY KEY (id_genre_pere, id_sous_genre)
);

--Relation entre utilisateur
create table relation_amitie (
    utilisateur1 INTEGER,
    utilisateur2 INTEGER,
    FOREIGN KEY(utilisateur1)  REFERENCES utilisateur(id_utilisateur),
    FOREIGN KEY(utilisateur2)  REFERENCES utilisateur(id_utilisateur),
    PRIMARY KEY (utilisateur1, utilisateur2)
);

create table relation_follow (
    utilisateur1 INTEGER,
    utilisateur2 INTEGER,
    FOREIGN KEY(utilisateur1)  REFERENCES utilisateur(id_utilisateur),
    FOREIGN KEY(utilisateur2)  REFERENCES utilisateur(id_utilisateur),
    PRIMARY KEY (utilisateur1, utilisateur2)
);

-- Relation entre les utilisateurs et les groupes
create table relation_appartenance(
    id_personne INTEGER,
    id_groupe INTEGER,
    FOREIGN KEY(id_personne)  REFERENCES personne (id_personne),
    FOREIGN KEY(id_groupe)  REFERENCES groupe (id_groupe),
    PRIMARY KEY (id_personne, id_groupe)
);

-- Relation entre les concerts et les differentes entités

create table relation_groupe_concert_passe(
    id_concert INTEGER,
    id_groupe INTEGER,
    FOREIGN KEY(id_concert)  REFERENCES concert_passe(id_concert),
    FOREIGN KEY(id_groupe)  REFERENCES groupe (id_groupe),
    PRIMARY KEY (id_concert, id_groupe)
);

create table relation_groupe_concert_futur(
    id_concert INTEGER,
    id_groupe INTEGER,
    FOREIGN KEY(id_concert)  REFERENCES concert_futur(id_concert),
    FOREIGN KEY(id_groupe)  REFERENCES groupe (id_groupe),
    PRIMARY KEY (id_concert, id_groupe)
);

create table relation_utilisateur_concert_passe(
    id_concert INTEGER,
    id_utilisateur INTEGER,
    FOREIGN KEY(id_concert)  REFERENCES concert_passe(id_concert),
    FOREIGN KEY(id_utilisateur)  REFERENCES utilisateur (id_utilisateur),
    PRIMARY KEY (id_concert, id_utilisateur)
);
create table relation_utilisateur_concert_futur(
    id_concert INTEGER,
    id_utilisateur INTEGER,
    FOREIGN KEY(id_concert)  REFERENCES concert_futur(id_concert),
    FOREIGN KEY(id_utilisateur)  REFERENCES utilisateur (id_utilisateur),
    PRIMARY KEY (id_concert, id_utilisateur)
);

--Participation et interet 
create table relation_personne_interesse(
    id_concert INTEGER,
    id_personne INTEGER,
    FOREIGN KEY(id_concert)  REFERENCES concert_futur(id_concert),
    FOREIGN KEY(id_personne)  REFERENCES personne (id_personne),
    PRIMARY KEY (id_concert, id_personne)
);
create table relation_personne_participe(
    id_concert INTEGER,
    id_personne INTEGER,
    FOREIGN KEY(id_concert)  REFERENCES concert_futur(id_concert),
    FOREIGN KEY(id_personne)  REFERENCES personne (id_personne),
    PRIMARY KEY (id_concert, id_personne)
);
--Relations playlist et morceau 


create table relation_playlist_morceau(
    id_playlist INTEGER,
    id_morceau  INTEGER,
    FOREIGN KEY (id_playlist)  REFERENCES playlist  (id_playlist),
    FOREIGN KEY (id_morceau)  REFERENCES morceau  (id_morceau),
    PRIMARY KEY (id_playlist, id_morceau)
);touch

--Relation entre morceaux et genre
create table relation_morceau_genre(
    id_genre INTEGER,
    id_morceau  INTEGER,
    FOREIGN KEY (id_genre)  REFERENCES genre  (id_genre),
    FOREIGN KEY (id_morceau)  REFERENCES morceau  (id_morceau),
    PRIMARY KEY (id_genre, id_morceau)


);
--Tables en lien avec les avis sur les groupes, morceaux, lieux et concerts passés
create table avis_groupe(
    id_avis INTEGER,
    id_groupe  INTEGER,
    id_utilisateur INTEGER,
    FOREIGN KEY (id_avis)  REFERENCES avis  (id_avis),
    FOREIGN KEY (id_groupe)  REFERENCES groupe  (id_groupe),
    FOREIGN KEY (id_utilisateur)  REFERENCES utilisateur  (id_utilisateur),
    PRIMARY KEY (id_avis, id_groupe, id_utilisateur)

);

create table avis_lieu(
    id_avis INTEGER,
    id_lieu  INTEGER,
    id_utilisateur INTEGER,
    FOREIGN KEY (id_avis)  REFERENCES avis  (id_avis),
    FOREIGN KEY (id_lieu)  REFERENCES lieu  (id_lieu),
    FOREIGN KEY (id_utilisateur)  REFERENCES utilisateur  (id_utilisateur),
    PRIMARY KEY (id_avis, id_lieu, id_utilisateur)

);

create table avis_concert_futur(
    id_avis INTEGER,
    id_concert  INTEGER,
    id_utilisateur INTEGER,
    FOREIGN KEY (id_avis)  REFERENCES avis  (id_avis),
    FOREIGN KEY (id_concert)  REFERENCES concert_futur  (id_concert),
    FOREIGN KEY (id_utilisateur)  REFERENCES utilisateur  (id_utilisateur),
    PRIMARY KEY (id_avis, id_concert, id_utilisateur)

);

create table avis_morceau(
    id_avis INTEGER,
    id_morceau  INTEGER,
    id_utilisateur INTEGER,
    FOREIGN KEY (id_avis)  REFERENCES avis  (id_avis),
    FOREIGN KEY (id_morceau)  REFERENCES morceau  (id_morceau),
    FOREIGN KEY (id_utilisateur)  REFERENCES utilisateur  (id_utilisateur),
    PRIMARY KEY (id_avis, id_morceau, id_utilisateur)

);
--Tables des relation entre les tag et les entités avis,  les groupes, morceaux, lieux et concerts passés
create table avis_tag(
    id_avis INTEGER,
    id_tag  INTEGER,
    FOREIGN KEY (id_avis)  REFERENCES avis  (id_avis),
    FOREIGN KEY (id_tag)  REFERENCES tag  (id_tag),
    FOREIGN KEY (id_utilisateur)  REFERENCES utilisateur  (id_utilisateur),
    PRIMARY KEY (id_avis, id_tag, id_utilisateur)

);

create table groupe_tag(
    id_groupe INTEGER,
    id_tag  INTEGER,
    FOREIGN KEY (id_groupe)  REFERENCES groupe  (id_groupe),
    FOREIGN KEY (id_tag)  REFERENCES tag  (id_tag),
    PRIMARY KEY (id_groupe, id_tag)
);

create table concert_passe_tag(
    id_concert INTEGER,
    id_tag  INTEGER,
    FOREIGN KEY (id_concert)  REFERENCES concert_passe  (id_concert),
    FOREIGN KEY (id_tag)  REFERENCES tag  (id_tag),
    PRIMARY KEY (id_concert, id_tag)
);

create table morceau_tag(
    id_morceau INTEGER,
    id_tag  INTEGER,
    FOREIGN KEY (id_morceau)  REFERENCES morceau  (id_morceau),
    FOREIGN KEY (id_tag)  REFERENCES tag  (id_tag),
    PRIMARY KEY (id_morceau, id_tag)
);

create table lieu_tag(
    id_lieu INTEGER,
    id_tag  INTEGER,
    FOREIGN KEY (id_lieu)  REFERENCES lieu  (id_lieu),
    FOREIGN KEY (id_tag)  REFERENCES tag  (id_tag),
    PRIMARY KEY (id_lieu, id_tag)
);










