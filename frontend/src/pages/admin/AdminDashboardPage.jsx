import { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import { ProtectedRoute } from '../../routes/ProtectedRoute';

function AdminDashboardContent() {
  const { user } = useSelector(state => state.auth);
  const [stats, setStats] = useState({
    totalOrders: 0,
    totalRevenue: 0,
    totalProducts: 0,
    totalCustomers: 0
  });

  useEffect(() => {
    // Placeholder for fetching admin stats
    setStats({
      totalOrders: 1250,
      totalRevenue: 45230.50,
      totalProducts: 320,
      totalCustomers: 890
    });
  }, []);

  return (
    <div className="container mx-auto px-4 py-12">
      <h1 className="text-4xl font-bold mb-8">Admin Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-blue-600">
          <p className="text-gray-600 text-sm mb-2">Total Orders</p>
          <p className="text-3xl font-bold text-gray-900">{stats.totalOrders.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-green-600">
          <p className="text-gray-600 text-sm mb-2">Total Revenue</p>
          <p className="text-3xl font-bold text-gray-900">${stats.totalRevenue.toFixed(2)}</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-purple-600">
          <p className="text-gray-600 text-sm mb-2">Total Products</p>
          <p className="text-3xl font-bold text-gray-900">{stats.totalProducts.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-orange-600">
          <p className="text-gray-600 text-sm mb-2">Total Customers</p>
          <p className="text-3xl font-bold text-gray-900">{stats.totalCustomers.toLocaleString()}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-2xl font-semibold mb-4">Quick Actions</h2>
          <div className="space-y-2">
            <button className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 text-left pl-4">
              → Manage Products
            </button>
            <button className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 text-left pl-4">
              → View Orders
            </button>
            <button className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 text-left pl-4">
              → Manage Users
            </button>
            <button className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 text-left pl-4">
              → View Reports
            </button>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-2xl font-semibold mb-4">Recent Orders</h2>
          <p className="text-gray-600 text-sm">Coming soon - Real-time order tracking</p>
        </div>
      </div>
    </div>
  );
}

export default function AdminDashboardPage() {
  return (
    <ProtectedRoute adminOnly>
      <AdminDashboardContent />
    </ProtectedRoute>
  );
}
