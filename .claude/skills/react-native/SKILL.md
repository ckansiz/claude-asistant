---
name: react-native
description: This skill should be used when the user asks to "build a React Native app", "add an Expo screen", "use Expo Router", "set up NativeWind", "add a Zustand store", or works on React Native / Expo mobile projects.
version: 1.0.0
---

# React Native / Expo Standards

Apply when implementing React Native + Expo (managed workflow) mobile apps. Default mobile stack — use Flutter only when the project already uses it.

## Stack

- **Framework**: Expo SDK (latest stable) — managed workflow
- **Navigation**: Expo Router (file-based, App Router analogy)
- **Styling**: NativeWind v4 (Tailwind class names on native components)
- **State**: Zustand (global) + TanStack Query v5 (server state)
- **Types**: TypeScript strict mode — see `typescript` skill
- **API**: Generated types from `api.generated.ts` (see `api-contract` skill)

## Project Structure

```
app/
  (tabs)/           # Tab navigator
    index.tsx
    profile.tsx
  (auth)/           # Auth group (no tab bar)
    sign-in.tsx
    sign-up.tsx
  _layout.tsx       # Root layout (fonts, providers)
  +not-found.tsx
components/
  ui/               # Reusable primitives (Button, Card, Input, etc.)
  [feature]/        # Feature-specific components
hooks/
  use-auth.ts
  use-[feature].ts
stores/
  auth.store.ts
  [feature].store.ts
lib/
  api.ts            # Typed fetch wrapper
  utils.ts
assets/
  fonts/
  images/
```

## Navigation (Expo Router)

File-based — same mental model as Next.js App Router. `app/products/[id].tsx` → `/products/:id`.

```tsx
import { useLocalSearchParams, router } from 'expo-router'

export default function ProductScreen() {
  const { id } = useLocalSearchParams<{ id: string }>()
  return (
    <View>
      <Button onPress={() => router.back()}>Back</Button>
    </View>
  )
}
```

## Styling (NativeWind)

```tsx
// ✅ NativeWind — Tailwind classes on native
import { View, Text, Pressable } from 'react-native'

export function Card({ title }: { title: string }) {
  return (
    <View className="rounded-xl bg-white p-4 shadow-sm">
      <Text className="text-base font-semibold text-zinc-900">{title}</Text>
    </View>
  )
}

// ❌ StyleSheet — verbose, no design tokens
const styles = StyleSheet.create({ card: { borderRadius: 12, ... } })
```

## Safe Areas & Platform Differences

```tsx
import { useSafeAreaInsets } from 'react-native-safe-area-context'
import { Platform } from 'react-native'

export function Header() {
  const insets = useSafeAreaInsets()
  return (
    <View style={{ paddingTop: insets.top }} className="bg-white px-4 pb-3">
      <Text className="text-xl font-bold">Title</Text>
    </View>
  )
}

const isAndroid = Platform.OS === 'android'
```

## Keyboard Handling

Always wrap forms in `KeyboardAvoidingView`:

```tsx
import { KeyboardAvoidingView, Platform } from 'react-native'

<KeyboardAvoidingView
  behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
  className="flex-1"
>
  {/* form content */}
</KeyboardAvoidingView>
```

## Server State (TanStack Query)

```tsx
// hooks/use-products.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import type { components } from '@/types/api.generated'

type Product = components['schemas']['ProductDto']

export function useProducts() {
  return useQuery({
    queryKey: ['products'],
    queryFn: () => api.get<Product[]>('/products'),
  })
}

export function useCreateProduct() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (data: CreateProductRequest) => api.post('/products', data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['products'] }),
  })
}
```

## Global State (Zustand)

```tsx
// stores/auth.store.ts
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import AsyncStorage from '@react-native-async-storage/async-storage'

interface AuthState {
  token: string | null
  user: User | null
  setToken: (token: string) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      setToken: (token) => set({ token }),
      logout: () => set({ token: null, user: null }),
    }),
    { name: 'auth', storage: createJSONStorage(() => AsyncStorage) }
  )
)
```

## API Client

```tsx
// lib/api.ts — typed fetch wrapper
const BASE_URL = process.env.EXPO_PUBLIC_API_URL

async function request<T>(method: string, path: string, body?: unknown): Promise<T> {
  const token = useAuthStore.getState().token
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  })
  if (!res.ok) throw new Error(`${method} ${path} → ${res.status}`)
  return res.json() as Promise<T>
}

export const api = {
  get: <T>(path: string) => request<T>('GET', path),
  post: <T>(path: string, body: unknown) => request<T>('POST', path, body),
  put: <T>(path: string, body: unknown) => request<T>('PUT', path, body),
  delete: <T>(path: string) => request<T>('DELETE', path),
}
```

## Environment Variables

```bash
# .env — prefix with EXPO_PUBLIC_ to expose to client
EXPO_PUBLIC_API_URL=http://localhost:5000
```

## Common Patterns

### Loading + Error states
```tsx
const { data, isLoading, error } = useProducts()

if (isLoading) return <ActivityIndicator className="flex-1" />
if (error) return <ErrorView message={error.message} />
```

### FlatList (never ScrollView for lists)
```tsx
<FlatList
  data={products}
  keyExtractor={(item) => item.id}
  renderItem={({ item }) => <ProductCard product={item} />}
  contentContainerClassName="px-4 pb-8"
  showsVerticalScrollIndicator={false}
/>
```

## Build & Deploy

```bash
npx expo start                                    # Development
eas build --profile preview --platform all        # Preview (OTA updates)
eas build --profile production --platform all     # Production
eas submit --platform all
```

## Code Style

- `async/await` — never `.then()` chains
- Functional components only — no class components
- Custom hooks for all business logic (`use-*.ts`)
- Props interface for every component
- No inline styles — NativeWind classes only

## Companion Skills

- `typescript` — strict mode standards
- `commits` — commit conventions
- `api-contract` — load when project has .NET backend
