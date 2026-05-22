export interface Track {
  id: number
  title: string
  artist: string
  album: string
  duration: number
  coverColor: string
  accentColor: string
}

export const PLAYLIST: Track[] = [
  {
    id: 0,
    title: 'Neon Drift',
    artist: 'Synthwave Collective',
    album: 'Electric Dreams',
    duration: 214,
    coverColor: '#7B2FBE',
    accentColor: '#C77DFF'
  },
  {
    id: 1,
    title: 'Midnight Rain',
    artist: 'Luna Echo',
    album: 'Solstice',
    duration: 187,
    coverColor: '#1A535C',
    accentColor: '#4ECDC4'
  },
  {
    id: 2,
    title: 'Solar Flare',
    artist: 'Nova Pulse',
    album: 'Orbit',
    duration: 243,
    coverColor: '#C9430A',
    accentColor: '#FF8C42'
  },
  {
    id: 3,
    title: 'Deep Blue',
    artist: 'Ocean Drive',
    album: 'Tides',
    duration: 198,
    coverColor: '#0A3981',
    accentColor: '#4895EF'
  },
  {
    id: 4,
    title: 'Forest Walk',
    artist: 'Terra Sounds',
    album: 'Roots',
    duration: 221,
    coverColor: '#1B4332',
    accentColor: '#52B788'
  },
  {
    id: 5,
    title: 'Golden Hour',
    artist: 'Amber Waves',
    album: 'Warmth',
    duration: 205,
    coverColor: '#7D4E00',
    accentColor: '#F4A261'
  }
]

export function formatDuration(seconds: number): string {
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return `${m}:${s < 10 ? '0' : ''}${s}`
}
