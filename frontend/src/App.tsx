import React, { useState, useEffect } from 'react';
import { backend } from 'declarations/backend';

interface ICPData {
  price: number;
  marketCap: number;
  volume24h: number;
  priceChange24h: number;
  circulatingSupply: number;
  totalSupply: number;
  ath: number;
  athDate: string;
}

function App() {
  const [name, setName] = useState('');
  const [greeting, setGreeting] = useState('');
  const [icpData, setIcpData] = useState<ICPData | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const result = await backend.greet(name);
    setGreeting(result);
  };

  useEffect(() => {
    const fetchICPData = async () => {
      try {
        const data = await backend.getICPData();
        if (data) {
          setIcpData(data);
        } else {
          console.error('Failed to fetch ICP data');
        }
      } catch (error) {
        console.error('Error fetching ICP data:', error);
      }
    };

    fetchICPData();
    const interval = setInterval(fetchICPData, 60000); // Update every minute

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
      <h2>Internet Computer (ICP) Data</h2>
      {icpData ? (
        <div>
          <p>Current Price: ${icpData.price.toFixed(2)}</p>
          <p>Market Cap: ${icpData.marketCap.toLocaleString()}</p>
          <p>24h Trading Volume: ${icpData.volume24h.toLocaleString()}</p>
          <p>24h Price Change: {icpData.priceChange24h.toFixed(2)}%</p>
          <p>Circulating Supply: {icpData.circulatingSupply.toLocaleString()} ICP</p>
          <p>Total Supply: {icpData.totalSupply.toLocaleString()} ICP</p>
          <p>All Time High: ${icpData.ath.toFixed(2)} ({new Date(icpData.athDate).toLocaleDateString()})</p>
        </div>
      ) : (
        <p>Loading ICP data...</p>
      )}
    </div>
  );
}

export default App;