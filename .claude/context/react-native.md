# React Native / Expo Standards

## Stack

- **Framework**: Expo SDK (latest stable) — managed workflow
- **Navigation**: Expo Router (file-based, App Router analogy)
- **Styling**: NativeWind v4 (Tailwind class names on native components)
- **State**: Zustand (global) + TanStack Query v5 (server state)
- **Types**: TypeScript strict mode — see `typescript.md`
- **API**: Generated types from `api.generated.ts` (see `api-contract.md`)

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

```tsx
// File-based — same mental model as Next.js App Router
// app/products/[id].tsx → /products/:id

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

// Platform-specific behavior
const isAndroid = Platform.OS === 'android'
```

## Keyboard Handling

```tsx
import { KeyboardAvoidingView, Platform } from 'react-native'

// Always wrap forms in KeyboardAvoidingView
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

```tsx
// Access in code
const url = process.env.EXPO_PUBLIC_API_URL
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
# Development
npx expo start

# Preview build (OTA updates)
eas build --profile preview --platform all

# Production
eas build --profile production --platform all
eas submit --platform all
```

## Code Style

- `async/await` — no `.then()` chains
- Functional components only — no class components
- Custom hooks for all business logic (`use-*.ts`)
- Props interface for every component
- No inline styles — NativeWind classes only
