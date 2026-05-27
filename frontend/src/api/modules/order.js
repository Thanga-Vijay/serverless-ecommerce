import axiosInstance from '../axios'

const API_ENDPOINTS = {
  ORDERS_LIST: '/orders',
  ORDERS_CREATE: '/orders',
  ORDERS_DETAIL: (id) => `/orders/${id}`,
  ORDERS_USER: '/orders/user',
  ORDERS_ALL: '/orders/admin',
  ORDERS_CANCEL: (id) => `/orders/${id}/cancel`,
  ORDERS_STATUS: (id) => `/orders/${id}/status`
}

export const orderAPI = {
  getUserOrders: async (page = 1, limit = 10) => {
    const response = await axiosInstance.get(API_ENDPOINTS.ORDERS_USER, {
      params: { page, limit }
    })
    return response.data
  },

  getOrderById: async (id) => {
    const response = await axiosInstance.get(API_ENDPOINTS.ORDERS_DETAIL(id))
    return response.data
  },

  createOrder: async (orderData) => {
    const response = await axiosInstance.post(API_ENDPOINTS.ORDERS_CREATE, orderData)
    return response.data
  },

  getAllOrders: async (status, page = 1, limit = 10) => {
    const response = await axiosInstance.get(API_ENDPOINTS.ORDERS_ALL, {
      params: { status, page, limit }
    })
    return response.data
  },

  updateOrderStatus: async (id, status) => {
    const response = await axiosInstance.put(API_ENDPOINTS.ORDERS_STATUS(id), { status })
    return response.data
  },

  cancel: async (id) => {
    const response = await axiosInstance.post(API_ENDPOINTS.ORDERS_CANCEL(id))
    return response.data
  }
}
