import axiosInstance from '../axios'

const API_ENDPOINTS = {
  AUTH_LOGIN: '/auth/login',
  AUTH_REGISTER: '/auth/register',
  AUTH_LOGOUT: '/auth/logout',
  AUTH_REFRESH: '/auth/refresh',
  AUTH_PROFILE: '/auth/profile'
}

export const authAPI = {
  login: async (email, password) => {
    const response = await axiosInstance.post(API_ENDPOINTS.AUTH_LOGIN, {
      email,
      password
    })
    return response.data
  },

  register: async (userData) => {
    const response = await axiosInstance.post(API_ENDPOINTS.AUTH_REGISTER, userData)
    return response.data
  },

  logout: async () => {
    const response = await axiosInstance.post(API_ENDPOINTS.AUTH_LOGOUT)
    return response.data
  },

  getProfile: async () => {
    const response = await axiosInstance.get(API_ENDPOINTS.AUTH_PROFILE)
    return response.data
  },

  refreshToken: async () => {
    const response = await axiosInstance.post(API_ENDPOINTS.AUTH_REFRESH)
    return response.data
  }
}
