import { createSlice } from '@reduxjs/toolkit'

const initialState = {
  orders: [],
  loading: false,
  error: null,
  currentOrder: null
}

const orderSlice = createSlice({
  name: 'order',
  initialState,
  reducers: {
    setLoading: (state, action) => {
      state.loading = action.payload
    },
    setOrders: (state, action) => {
      state.orders = action.payload
      state.loading = false
      state.error = null
    },
    setError: (state, action) => {
      state.error = action.payload
      state.loading = false
    },
    createOrder: (state, action) => {
      state.currentOrder = action.payload
      state.orders.push(action.payload)
      state.loading = false
      state.error = null
    },
    setCurrentOrder: (state, action) => {
      state.currentOrder = action.payload
    },
    clearCurrentOrder: (state) => {
      state.currentOrder = null
    }
  }
})

export const {
  setLoading,
  setOrders,
  setError,
  createOrder,
  setCurrentOrder,
  clearCurrentOrder
} = orderSlice.actions

export default orderSlice.reducer
