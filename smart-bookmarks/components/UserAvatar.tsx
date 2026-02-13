'use client'

import { useState } from 'react'

interface UserAvatarProps {
  avatarUrl?: string
  name?: string
  email?: string
}

export default function UserAvatar({ avatarUrl, name, email }: UserAvatarProps) {
  const fallbackUrl =
    'https://ui-avatars.com/api/?name=' +
    encodeURIComponent(name || email || 'User')

  const [imgSrc, setImgSrc] = useState(
    avatarUrl || '/default-avatar.png'
  )

  return (
    <img
      src={imgSrc}
      alt={name || email || 'User'}
      className="w-8 h-8 rounded-full"
      onError={() => setImgSrc(fallbackUrl)}
    />
  )
}
