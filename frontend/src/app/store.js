import { configureStore } from '@reduxjs/toolkit'
import authReducer from '../redux/auth/authSlice'
import productReducer from '../redux/product/productSlice'
import cartReducer from '../redux/cart/cartSlice'
import orderReducer from '../redux/order/orderSlice'

export const store = configureStore({
  reducer: {
    auth: authReducer,
    products: productReducer,
    cart: cartReducer,
    orders: orderReducer
  }
})

export default store
