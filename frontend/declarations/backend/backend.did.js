export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'getBitcoinPrice' : IDL.Func([], [IDL.Opt(IDL.Float64)], []),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
  });
};
export const init = ({ IDL }) => { return []; };
