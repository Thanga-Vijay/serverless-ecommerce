import { useDispatch } from 'react-redux';
import { removeFromCart, updateQuantity } from '../../redux/cart/cartSlice';

export default function CartItem({ item }) {
  const dispatch = useDispatch();

  const handleQuantityChange = (newQuantity) => {
    if (newQuantity > 0) {
      dispatch(updateQuantity({ id: item.id, quantity: newQuantity }));
    }
  };

  return (
    <div className="flex items-center space-x-4 bg-white p-4 rounded-lg border border-gray-200">
      <div className="w-20 h-20 bg-gray-100 rounded overflow-hidden">
        {item.imageUrl && (
          <img 
            src={item.imageUrl} 
            alt={item.name}
            className="w-full h-full object-cover"
          />
        )}
      </div>

      <div className="flex-grow">
        <h3 className="font-semibold text-gray-900">{item.name}</h3>
        <p className="text-gray-600 text-sm">${item.price.toFixed(2)} each</p>
      </div>

      <div className="flex items-center space-x-2">
        <button 
          onClick={() => handleQuantityChange(item.quantity - 1)}
          className="bg-gray-200 hover:bg-gray-300 px-2 py-1 rounded text-sm"
        >
          -
        </button>
        <input 
          type="number" 
          value={item.quantity} 
          onChange={(e) => handleQuantityChange(parseInt(e.target.value) || 1)}
          className="w-12 px-2 py-1 border border-gray-300 rounded text-center text-sm"
        />
        <button 
          onClick={() => handleQuantityChange(item.quantity + 1)}
          className="bg-gray-200 hover:bg-gray-300 px-2 py-1 rounded text-sm"
        >
          +
        </button>
      </div>

      <div className="text-right min-w-24">
        <p className="font-semibold text-gray-900">
          ${(item.price * item.quantity).toFixed(2)}
        </p>
      </div>

      <button 
        onClick={() => dispatch(removeFromCart(item.id))}
        className="text-red-600 hover:text-red-700 font-medium text-sm"
      >
        Remove
      </button>
    </div>
  );
}
