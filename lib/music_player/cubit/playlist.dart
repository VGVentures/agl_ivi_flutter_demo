import 'package:agl_ivi_vgv_demo/music_player/cubit/track.dart';

/// Ten Creative Commons-licensed tracks from the Internet Archive's
/// "CC Music For Commercial Use" collection, streamed directly from
/// archive.org. These tracks have no real cover art (archive.org only offers
/// an auto-generated waveform thumbnail), so `artAsset` points at a bundled
/// generated placeholder instead, one per track, so playback still shows
/// artwork without a network connection.
const playlist = <Track>[
  Track(
    title: 'Quel tatuaggio',
    artist: 'Cristian Battista',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Cristian_Battista_-_Quel_tatuaggio.mp3',
    artAsset: 'assets/album_art/Cristian_Battista_-_Quel_tatuaggio.png',
    duration: Duration(minutes: 3, seconds: 19),
  ),
  Track(
    title: 'Crazy Train',
    artist: 'Dickey F',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Dickey_F_-_Crazy_Train.mp3',
    artAsset: 'assets/album_art/Dickey_F_-_Crazy_Train.png',
    duration: Duration(minutes: 3, seconds: 28),
  ),
  Track(
    title: 'Florida Mama',
    artist: 'Dickey F',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Dickey_F_-_Florida_Mama.mp3',
    artAsset: 'assets/album_art/Dickey_F_-_Florida_Mama.png',
    duration: Duration(minutes: 3, seconds: 46),
  ),
  Track(
    title: 'Vi Veri Veniversum Vivus Vici',
    artist: 'Eugene Frank',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Eugene_Frank_-_Vi_Veri_Veniversum_Vivus_Vici.mp3',
    artAsset:
        'assets/album_art/'
        'Eugene_Frank_-_Vi_Veri_Veniversum_Vivus_Vici.png',
    duration: Duration(minutes: 3, seconds: 25),
  ),
  Track(
    title: 'Had My Share',
    artist: 'Freeky Cleen & Dickey F',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Freeky_Cleen_and_Dickey_F_-_Had_My_Share.mp3',
    artAsset: 'assets/album_art/Freeky_Cleen_and_Dickey_F_-_Had_My_Share.png',
    duration: Duration(minutes: 3, seconds: 52),
  ),
  Track(
    title: 'Priezhai v Kokshetau',
    artist: 'Green Team',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Green_Team_-_Prijezaj_w_Kokszetau.mp3',
    artAsset: 'assets/album_art/Green_Team_-_Prijezaj_w_Kokszetau.png',
    duration: Duration(minutes: 3, seconds: 36),
  ),
  Track(
    title: 'La valse',
    artist: 'Julien Allioux',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Julien_Allioux_-_La_valse.mp3',
    artAsset: 'assets/album_art/Julien_Allioux_-_La_valse.png',
    duration: Duration(minutes: 3, seconds: 44),
  ),
  Track(
    title: 'Kamien',
    artist: 'Miles Away',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Miles_Away_-_Kamien.mp3',
    artAsset: 'assets/album_art/Miles_Away_-_Kamien.png',
    duration: Duration(minutes: 3, seconds: 32),
  ),
  Track(
    title: 'Spacer po niebie',
    artist: 'MuzaOla',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'MuzaOla_-_Spacer_po_niebie.mp3',
    artAsset: 'assets/album_art/MuzaOla_-_Spacer_po_niebie.png',
    duration: Duration(minutes: 3, seconds: 11),
  ),
  Track(
    title: 'The Crew Mourns The Death Of Their Captain',
    artist: 'Olga Scotland',
    url:
        'https://archive.org/download/CcMusicForCommercialUse/'
        'Olga_Scotland_-_The_Crew_Mourns_The_Death_Of_Their_Captain.mp3',
    artAsset:
        'assets/album_art/'
        'Olga_Scotland_-_The_Crew_Mourns_The_Death_Of_Their_Captain.png',
    duration: Duration(minutes: 4, seconds: 58),
  ),
];
