import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface ICPData {
  'ath' : number,
  'athDate' : string,
  'circulatingSupply' : number,
  'marketCap' : number,
  'volume24h' : number,
  'totalSupply' : number,
  'priceChange24h' : number,
  'price' : number,
}
export interface _SERVICE {
  'getICPData' : ActorMethod<[], ICPData>,
  'greet' : ActorMethod<[string], string>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
