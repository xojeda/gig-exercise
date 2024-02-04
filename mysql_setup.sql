--Create DBA's administration user.
CREATE USER 'gigdbdmn'@'192.168.56.%' IDENTIFIED BY 'Temporal.2023';
--Grant all privileges over the node.
GRANT ALL PRIVILEGES ON *.* TO 'gigdbdmn'@'192.168.56.%' WITH GRANT OPTION;
--Flush privileges
FLUSH PRIVILEGES;

--Create the new database.
CREATE DATABASE IF NOT EXISTS MusicStore;

--Use our new database
USE MusicStore;

--Create admin user for the database only.
CREATE USER 'admin'@'192.168.56.%' IDENTIFIED BY 'Temporal.2023';
GRANT ALL PRIVILEGES ON MusicStore.* TO 'admin'@'192.168.56.%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

--Create development accounts.
CREATE USER 'devel01'@'192.168.56.%' IDENTIFIED BY 'Temporal.0001';
CREATE USER 'devel02'@'192.168.56.%' IDENTIFIED BY 'Temporal.0002';
CREATE USER 'devel03'@'192.168.56.%' IDENTIFIED BY 'Temporal.0003';
CREATE USER 'devel04'@'192.168.56.%' IDENTIFIED BY 'Temporal.0004';
CREATE USER 'devel05'@'192.168.56.%' IDENTIFIED BY 'Temporal.0005';
CREATE USER 'devel06'@'192.168.56.%' IDENTIFIED BY 'Temporal.0006';
CREATE USER 'devel07'@'192.168.56.%' IDENTIFIED BY 'Temporal.0007';
CREATE USER 'devel08'@'192.168.56.%' IDENTIFIED BY 'Temporal.0008';
CREATE USER 'devel09'@'192.168.56.%' IDENTIFIED BY 'Temporal.0009';
CREATE USER 'devel10'@'192.168.56.%' IDENTIFIED BY 'Temporal.0010';

--Grant permissions to all devel users.
GRANT SELECT ON MusicStore.* TO 'devel01'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel02'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel03'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel04'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel05'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel06'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel07'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel08'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel09'@'192.168.56.%';
GRANT SELECT ON MusicStore.* TO 'devel10'@'192.168.56.%';

--Flush Privileges.
FLUSH PRIVILEGES;

--Create tables.
CREATE TABLE IF NOT EXISTS artists (
  artist_id INT AUTO_INCREMENT PRIMARY KEY,
  artist_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS albumns (
  album_id INT AUTO_INCREMENT PRIMARY KEY,
  album_name VARCHAR(50) NOT NULL,
  artist_id INT NOT NULL,
  FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE IF NOT EXISTS tracks (
  track_id INT AUTO_INCREMENT PRIMARY KEY,
  track_name VARCHAR(50) NOT NULL,
  track_genre VARCHAR(50) NOT NULL,
  album_id INT,
  FOREIGN KEY (album_id) REFERENCES albumns(album_id)
);

CREATE TABLE IF NOT EXISTS merch (
  merch_id INT AUTO_INCREMENT PRIMARY KEY,
  merch_name VARCHAR(50) NOT NULL,
  merch_descritpiton VARCHAR(250) NOT NULL,
  merch_price FLOAT NOT NULL
);