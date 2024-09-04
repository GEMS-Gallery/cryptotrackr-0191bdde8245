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
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const result = await backend.greet(name);
    setGreeting(result);
  };

  useEffect(() => {
    const fetchICPData = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await backend.getICPData();
        setIcpData(data);
      } catch (error) {
        console.error('Error fetching ICP data:', error);
        setError('Failed to fetch ICP data. Please try again later.');
      } finally {
        setLoading(false);
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
      {loading && <p>Loading ICP data...</p>}
      {error && <p style={{ color: 'red' }}>{error}</p>}
      {icpData && !loading && !error && (
        <div>
          <p>Current Price: ${icpData.price?.toFixed(2) ?? 'N/A'}</p>
          <p>Market Cap: ${icpData.marketCap?.toLocaleString() ?? 'N/A'}</p>
          <p>24h Trading Volume: ${icpData.volume24h?.toLocaleString() ?? 'N/A'}</p>
          <p>24h Price Change: {icpData.priceChange24h?.toFixed(2) ?? 'N/A'}%</p>
          <p>Circulating Supply: {icpData.circulatingSupply?.toLocaleString() ?? 'N/A'} ICP</p>
          <p>Total Supply: {icpData.totalSupply?.toLocaleString() ?? 'N/A'} ICP</p>
          <p>All Time High: ${icpData.ath?.toFixed(2) ?? 'N/A'} ({icpData.athDate ? new Date(icpData.athDate).toLocaleDateString() : 'N/A'})</p>
        </div>
      )}
    </div>
  );
}

export default App;