export const idlFactory = ({ IDL }) => {
  const ICPData = IDL.Record({
    'ath' : IDL.Float64,
    'athDate' : IDL.Text,
    'circulatingSupply' : IDL.Float64,
    'marketCap' : IDL.Float64,
    'volume24h' : IDL.Float64,
    'totalSupply' : IDL.Float64,
    'priceChange24h' : IDL.Float64,
    'price' : IDL.Float64,
  });
  return IDL.Service({
    'getICPData' : IDL.Func([], [IDL.Opt(ICPData)], []),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
  });
};
export const init = ({ IDL }) => { return []; };
