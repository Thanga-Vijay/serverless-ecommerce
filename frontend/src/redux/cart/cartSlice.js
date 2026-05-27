import { createSlice } from '@reduxjs/toolkit'

const initialState = {
  items: [],
  subtotal: 0,
  total: 0,
  tax: 0,
  loading: false,
  error: null
}

const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    addToCart: (state, action) => {
      const existingItem = state.items.find(
        (item) => item.id === action.payload.id
      )

      if (existingItem) {
        existingItem.quantity += action.payload.quantity || 1
      } else {
        state.items.push({ ...action.payload, quantity: action.payload.quantity || 1 })
      }
      calculateTotals(state)
    },
    removeFromCart: (state, action) => {
      state.items = state.items.filter((item) => item.id !== action.payload)
      calculateTotals(state)
    },
    updateQuantity: (state, action) => {
      const item = state.items.find((item) => item.id === action.payload.id)
      if (item) {
        item.quantity = action.payload.quantity
      }
      calculateTotals(state)
    },
    clearCart: (state) => {
      state.items = []
      state.subtotal = 0
      state.total = 0
      state.tax = 0
    },
    setCart: (state, action) => {
      state.items = action.payload
      calculateTotals(state)
    }
  }
})

function calculateTotals(state) {
  state.subtotal = state.items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  )
  state.tax = state.subtotal * 0.1
  state.total = state.subtotal + state.tax
}

export const {
  addToCart,
  removeFromCart,
  updateQuantity,
  clearCart,
  setCart
} = cartSlice.actions

export default cartSlice.reducer
