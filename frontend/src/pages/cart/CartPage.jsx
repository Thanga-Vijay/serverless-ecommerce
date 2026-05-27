import { useNavigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import CartItem from '../../components/cart/CartItem';

export default function CartPage() {
  const navigate = useNavigate();
  const { items, subtotal, tax, total } = useSelector(state => state.cart);
  const { isAuthenticated } = useSelector(state => state.auth);

  if (items.length === 0) {
    return (
      <div className="container mx-auto px-4 py-12">
        <h1 className="text-4xl font-bold mb-8">Shopping Cart</h1>
        <div className="text-center py-12">
          <p className="text-gray-600 text-lg mb-6">Your cart is empty</p>
          <button 
            onClick={() => navigate('/products')}
            className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700"
          >
            Continue Shopping
          </button>
        </div>
      </div>
    );
  }

  const handleCheckout = () => {
    if (!isAuthenticated) {
      navigate('/login', { state: { from: { pathname: '/checkout' } } });
    } else {
      navigate('/checkout');
    }
  };

  return (
    <div className="container mx-auto px-4 py-12">
      <h1 className="text-4xl font-bold mb-8">Shopping Cart</h1>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          <div className="space-y-4">
            {items.map(item => (
              <CartItem key={`${item.id}-${item.quantity}`} item={item} />
            ))}
          </div>

          <button 
            onClick={() => navigate('/products')}
            className="mt-6 text-blue-600 hover:text-blue-700 font-medium"
          >
            ← Continue Shopping
          </button>
        </div>

        <div className="bg-white rounded-lg shadow p-6 border border-gray-200 h-fit">
          <h2 className="text-2xl font-semibold mb-6">Order Summary</h2>

          <div className="space-y-3 mb-6 pb-6 border-b border-gray-200">
            <div className="flex justify-between">
              <span className="text-gray-600">Subtotal</span>
              <span className="font-medium">${subtotal.toFixed(2)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Tax (10%)</span>
              <span className="font-medium">${tax.toFixed(2)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Shipping</span>
              <span className="font-medium text-green-600">FREE</span>
            </div>
          </div>

          <div className="flex justify-between mb-6 text-lg font-bold">
            <span>Total</span>
            <span className="text-blue-600">${total.toFixed(2)}</span>
          </div>

          <button 
            onClick={handleCheckout}
            className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 mb-2"
          >
            Proceed to Checkout
          </button>

          <button 
            onClick={() => navigate('/products')}
            className="w-full bg-gray-100 text-gray-800 py-3 rounded-lg font-semibold hover:bg-gray-200"
          >
            Continue Shopping
          </button>
        </div>
      </div>
    </div>
  );
}
