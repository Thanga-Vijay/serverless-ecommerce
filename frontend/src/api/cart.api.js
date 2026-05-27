import axiosInstance from './axios'

const API_ENDPOINTS = {
  CART_GET: '/cart',
  CART_ADD: '/cart/items',
  CART_UPDATE: (itemId) => `/cart/items/${itemId}`,
  CART_REMOVE: (itemId) => `/cart/items/${itemId}`,
  CART_CLEAR: '/cart'
}

export const cartApi = {
  getCart: async () => {
    const response = await axiosInstance.get(API_ENDPOINTS.CART_GET)
    return response.data
  },

  addItem: async (productId, quantity) => {
    const response = await axiosInstance.post(API_ENDPOINTS.CART_ADD, {
      productId,
      quantity
    })
    return response.data
  },

  updateItem: async (itemId, quantity) => {
    const response = await axiosInstance.put(API_ENDPOINTS.CART_UPDATE(itemId), {
      quantity
    })
    return response.data
  },

  removeItem: async (itemId) => {
    const response = await axiosInstance.delete(API_ENDPOINTS.CART_REMOVE(itemId))
    return response.data
  },

  clearCart: async () => {
    const response = await axiosInstance.delete(API_ENDPOINTS.CART_CLEAR)
    return response.data
  }
}

export default cartApi
