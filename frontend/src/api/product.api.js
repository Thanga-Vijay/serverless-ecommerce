import axiosInstance from './axios'

const API_ENDPOINTS = {
  PRODUCTS_LIST: '/products',
  PRODUCTS_DETAIL: (id) => `/products/${id}`,
  PRODUCTS_SEARCH: '/products/search'
}

export const productApi = {
  getAll: async (page = 1, limit = 20) => {
    const response = await axiosInstance.get(API_ENDPOINTS.PRODUCTS_LIST, {
      params: { page, limit }
    })
    return response.data
  },

  getById: async (id) => {
    const response = await axiosInstance.get(API_ENDPOINTS.PRODUCTS_DETAIL(id))
    return response.data
  },

  search: async (query, category, minPrice, maxPrice) => {
    const response = await axiosInstance.get(API_ENDPOINTS.PRODUCTS_SEARCH, {
      params: { query, category, minPrice, maxPrice }
    })
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

export default productApi
