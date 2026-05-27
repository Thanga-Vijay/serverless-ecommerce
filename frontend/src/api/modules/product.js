import axiosInstance from '../axios'

const API_ENDPOINTS = {
  PRODUCTS_LIST: '/products',
  PRODUCTS_DETAIL: (id) => `/products/${id}`,
  PRODUCTS_SEARCH: '/products/search',
  PRODUCTS_CREATE: '/products',
  PRODUCTS_UPDATE: (id) => `/products/${id}`,
  PRODUCTS_DELETE: (id) => `/products/${id}`
}

export const productAPI = {
  getProducts: async (page = 1, limit = 20) => {
    const response = await axiosInstance.get(API_ENDPOINTS.PRODUCTS_LIST, {
      params: { page, limit }
    })
    return response.data
  },

  getProductById: async (id) => {
    const response = await axiosInstance.get(API_ENDPOINTS.PRODUCTS_DETAIL(id))
    return response.data
  },

  search: async (query, category, minPrice, maxPrice) => {
    const response = await axiosInstance.get(API_ENDPOINTS.PRODUCTS_SEARCH, {
      params: { query, category, minPrice, maxPrice }
    })
    return response.data
  },

  createProduct: async (productData) => {
    const response = await axiosInstance.post(API_ENDPOINTS.PRODUCTS_CREATE, productData)
    return response.data
  },

  updateProduct: async (id, productData) => {
    const response = await axiosInstance.put(API_ENDPOINTS.PRODUCTS_UPDATE(id), productData)
    return response.data
  },

  deleteProduct: async (id) => {
    const response = await axiosInstance.delete(API_ENDPOINTS.PRODUCTS_DELETE(id))
    return response.data
  },

  getPresignedUrl: async (fileName, fileType) => {
    const response = await axiosInstance.post('/products/presigned-url', {
      fileName,
      fileType
    })
    return response.data
  }
}
