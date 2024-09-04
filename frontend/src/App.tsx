import React, { useState, useEffect } from 'react';
import { backend } from 'declarations/backend';

function App() {
  const [name, setName] = useState('');
  const [greeting, setGreeting] = useState('');
  const [bitcoinPrice, setBitcoinPrice] = useState<number | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const result = await backend.greet(name);
    setGreeting(result);
  };

  useEffect(() => {
    const fetchBitcoinPrice = async () => {
      try {
        const price = await backend.getBitcoinPrice();
        if (price !== null) {
          setBitcoinPrice(price);
        } else {
          console.error('Failed to fetch Bitcoin price');
        }
      } catch (error) {
        console.error('Error fetching Bitcoin price:', error);
      }
    };

    fetchBitcoinPrice();
    const interval = setInterval(fetchBitcoinPrice, 60000); // Update every minute

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="App">
      <h1>Internet Computer App</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Enter your name"
        />
        <button type="submit">Greet</button>
      </form>
      {greeting && <p>{greeting}</p>}
      <h2>Bitcoin Price</h2>
      {bitcoinPrice !== null ? (
        <p>${bitcoinPrice.toFixed(2)} USD</p>
      ) : (
        <p>Loading Bitcoin price...</p>
      )}
    </div>
  );
}

export default App;