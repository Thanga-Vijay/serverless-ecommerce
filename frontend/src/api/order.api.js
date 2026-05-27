import axiosInstance from './axios'

const API_ENDPOINTS = {
  ORDERS_LIST: '/orders',
  ORDERS_CREATE: '/orders',
  ORDERS_DETAIL: (id) => `/orders/${id}`,
  ORDERS_CANCEL: (id) => `/orders/${id}/cancel`
}

export const orderApi = {
  getAll: async (page = 1, limit = 10) => {
    const response = await axiosInstance.get(API_ENDPOINTS.ORDERS_LIST, {
      params: { page, limit }
    })
    return response.data
  },

  getById: async (id) => {
    const response = await axiosInstance.get(API_ENDPOINTS.ORDERS_DETAIL(id))
    return response.data
  },

  create: async (orderData) => {
    const response = await axiosInstance.post(API_ENDPOINTS.ORDERS_CREATE, orderData)
    return response.data
  },

  cancel: async (id) => {
    const response = await axiosInstance.post(API_ENDPOINTS.ORDERS_CANCEL(id))
    return response.data
  }
}

export default orderApi
