// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.29.1
// 	protoc        v3.21.12
// source: policy.proto

package protobuf

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type AssetProtocolTag int32

const (
	AssetProtocolTag_ASSET_PROTOCOL_UNSPECIFIED AssetProtocolTag = 0
	AssetProtocolTag_ASSET_PROTOCOL_BTC         AssetProtocolTag = 1
	AssetProtocolTag_ASSET_PROTOCOL_EVM         AssetProtocolTag = 2
	AssetProtocolTag_ASSET_PROTOCOL_ERC20       AssetProtocolTag = 3
	AssetProtocolTag_ASSET_PROTOCOL_COSMOS      AssetProtocolTag = 4
)

// Enum value maps for AssetProtocolTag.
var (
	AssetProtocolTag_name = map[int32]string{
		0: "ASSET_PROTOCOL_UNSPECIFIED",
		1: "ASSET_PROTOCOL_BTC",
		2: "ASSET_PROTOCOL_EVM",
		3: "ASSET_PROTOCOL_ERC20",
		4: "ASSET_PROTOCOL_COSMOS",
	}
	AssetProtocolTag_value = map[string]int32{
		"ASSET_PROTOCOL_UNSPECIFIED": 0,
		"ASSET_PROTOCOL_BTC":         1,
		"ASSET_PROTOCOL_EVM":         2,
		"ASSET_PROTOCOL_ERC20":       3,
		"ASSET_PROTOCOL_COSMOS":      4,
	}
)

func (x AssetProtocolTag) Enum() *AssetProtocolTag {
	p := new(AssetProtocolTag)
	*p = x
	return p
}

func (x AssetProtocolTag) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (AssetProtocolTag) Descriptor() protoreflect.EnumDescriptor {
	return file_policy_proto_enumTypes[0].Descriptor()
}

func (AssetProtocolTag) Type() protoreflect.EnumType {
	return &file_policy_proto_enumTypes[0]
}

func (x AssetProtocolTag) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use AssetProtocolTag.Descriptor instead.
func (AssetProtocolTag) EnumDescriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{0}
}

type TransactionTag int32

const (
	TransactionTag_TRANSACTION_UNSPECIFIED TransactionTag = 0
	TransactionTag_TRANSACTION_IMMEDIATE   TransactionTag = 1
)

// Enum value maps for TransactionTag.
var (
	TransactionTag_name = map[int32]string{
		0: "TRANSACTION_UNSPECIFIED",
		1: "TRANSACTION_IMMEDIATE",
	}
	TransactionTag_value = map[string]int32{
		"TRANSACTION_UNSPECIFIED": 0,
		"TRANSACTION_IMMEDIATE":   1,
	}
)

func (x TransactionTag) Enum() *TransactionTag {
	p := new(TransactionTag)
	*p = x
	return p
}

func (x TransactionTag) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (TransactionTag) Descriptor() protoreflect.EnumDescriptor {
	return file_policy_proto_enumTypes[1].Descriptor()
}

func (TransactionTag) Type() protoreflect.EnumType {
	return &file_policy_proto_enumTypes[1]
}

func (x TransactionTag) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use TransactionTag.Descriptor instead.
func (TransactionTag) EnumDescriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{1}
}

type PolicyTag int32

const (
	PolicyTag_POLICY_UNSPECIFIED PolicyTag = 0
	PolicyTag_POLICY_ALL         PolicyTag = 1
	PolicyTag_POLICY_ANY         PolicyTag = 2
	PolicyTag_POLICY_SIGNATURE   PolicyTag = 3
	PolicyTag_POLICY_REF_LOCAL   PolicyTag = 4
	PolicyTag_POLICY_ASSETS      PolicyTag = 5
	PolicyTag_POLICY_LIST        PolicyTag = 6
	PolicyTag_POLICY_CLOSURE     PolicyTag = 7
	PolicyTag_POLICY_TABLE       PolicyTag = 16
	PolicyTag_POLICY_TRANSACTION PolicyTag = 17
	PolicyTag_POLICY_ASSET_FLOW  PolicyTag = 18
	PolicyTag_POLICY_REF_TEMP    PolicyTag = 255
)

// Enum value maps for PolicyTag.
var (
	PolicyTag_name = map[int32]string{
		0:   "POLICY_UNSPECIFIED",
		1:   "POLICY_ALL",
		2:   "POLICY_ANY",
		3:   "POLICY_SIGNATURE",
		4:   "POLICY_REF_LOCAL",
		5:   "POLICY_ASSETS",
		6:   "POLICY_LIST",
		7:   "POLICY_CLOSURE",
		16:  "POLICY_TABLE",
		17:  "POLICY_TRANSACTION",
		18:  "POLICY_ASSET_FLOW",
		255: "POLICY_REF_TEMP",
	}
	PolicyTag_value = map[string]int32{
		"POLICY_UNSPECIFIED": 0,
		"POLICY_ALL":         1,
		"POLICY_ANY":         2,
		"POLICY_SIGNATURE":   3,
		"POLICY_REF_LOCAL":   4,
		"POLICY_ASSETS":      5,
		"POLICY_LIST":        6,
		"POLICY_CLOSURE":     7,
		"POLICY_TABLE":       16,
		"POLICY_TRANSACTION": 17,
		"POLICY_ASSET_FLOW":  18,
		"POLICY_REF_TEMP":    255,
	}
)

func (x PolicyTag) Enum() *PolicyTag {
	p := new(PolicyTag)
	*p = x
	return p
}

func (x PolicyTag) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (PolicyTag) Descriptor() protoreflect.EnumDescriptor {
	return file_policy_proto_enumTypes[2].Descriptor()
}

func (PolicyTag) Type() protoreflect.EnumType {
	return &file_policy_proto_enumTypes[2]
}

func (x PolicyTag) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use PolicyTag.Descriptor instead.
func (PolicyTag) EnumDescriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{2}
}

type WitnessTag int32

const (
	WitnessTag_WITNESS_UNSPECIFIED          WitnessTag = 0
	WitnessTag_WITNESS_GUESS                WitnessTag = 1
	WitnessTag_WITNESS_ALL                  WitnessTag = 2
	WitnessTag_WITNESS_ANY                  WitnessTag = 3
	WitnessTag_WITNESS_PRECHECKED_SIGNATURE WitnessTag = 4
	WitnessTag_WITNESS_TABLE                WitnessTag = 5
	WitnessTag_WITNESS_EVAL                 WitnessTag = 6
	WitnessTag_WITNESS_REF                  WitnessTag = 7
)

// Enum value maps for WitnessTag.
var (
	WitnessTag_name = map[int32]string{
		0: "WITNESS_UNSPECIFIED",
		1: "WITNESS_GUESS",
		2: "WITNESS_ALL",
		3: "WITNESS_ANY",
		4: "WITNESS_PRECHECKED_SIGNATURE",
		5: "WITNESS_TABLE",
		6: "WITNESS_EVAL",
		7: "WITNESS_REF",
	}
	WitnessTag_value = map[string]int32{
		"WITNESS_UNSPECIFIED":          0,
		"WITNESS_GUESS":                1,
		"WITNESS_ALL":                  2,
		"WITNESS_ANY":                  3,
		"WITNESS_PRECHECKED_SIGNATURE": 4,
		"WITNESS_TABLE":                5,
		"WITNESS_EVAL":                 6,
		"WITNESS_REF":                  7,
	}
)

func (x WitnessTag) Enum() *WitnessTag {
	p := new(WitnessTag)
	*p = x
	return p
}

func (x WitnessTag) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (WitnessTag) Descriptor() protoreflect.EnumDescriptor {
	return file_policy_proto_enumTypes[3].Descriptor()
}

func (WitnessTag) Type() protoreflect.EnumType {
	return &file_policy_proto_enumTypes[3]
}

func (x WitnessTag) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use WitnessTag.Descriptor instead.
func (WitnessTag) EnumDescriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{3}
}

type Asset struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Tag           AssetProtocolTag `protobuf:"varint,1,opt,name=tag,proto3,enum=com.qredo.blackbird.AssetProtocolTag" json:"tag,omitempty"`
	ChainId       []byte           `protobuf:"bytes,2,opt,name=chain_id,json=chainId,proto3" json:"chain_id,omitempty"`
	AddressPrefix string           `protobuf:"bytes,3,opt,name=address_prefix,json=addressPrefix,proto3" json:"address_prefix,omitempty"`
	RawAddress    []byte           `protobuf:"bytes,5,opt,name=raw_address,json=rawAddress,proto3" json:"raw_address,omitempty"`
	Selector      []byte           `protobuf:"bytes,6,opt,name=selector,proto3" json:"selector,omitempty"`
}

func (x *Asset) Reset() {
	*x = Asset{}
	if protoimpl.UnsafeEnabled {
		mi := &file_policy_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Asset) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Asset) ProtoMessage() {}

func (x *Asset) ProtoReflect() protoreflect.Message {
	mi := &file_policy_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Asset.ProtoReflect.Descriptor instead.
func (*Asset) Descriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{0}
}

func (x *Asset) GetTag() AssetProtocolTag {
	if x != nil {
		return x.Tag
	}
	return AssetProtocolTag_ASSET_PROTOCOL_UNSPECIFIED
}

func (x *Asset) GetChainId() []byte {
	if x != nil {
		return x.ChainId
	}
	return nil
}

func (x *Asset) GetAddressPrefix() string {
	if x != nil {
		return x.AddressPrefix
	}
	return ""
}

func (x *Asset) GetRawAddress() []byte {
	if x != nil {
		return x.RawAddress
	}
	return nil
}

func (x *Asset) GetSelector() []byte {
	if x != nil {
		return x.Selector
	}
	return nil
}

type AssetFlow struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	AddressPrefix string            `protobuf:"bytes,1,opt,name=address_prefix,json=addressPrefix,proto3" json:"address_prefix,omitempty"`
	CookedAddress string            `protobuf:"bytes,2,opt,name=cooked_address,json=cookedAddress,proto3" json:"cooked_address,omitempty"`
	RawAddress    []byte            `protobuf:"bytes,3,opt,name=raw_address,json=rawAddress,proto3" json:"raw_address,omitempty"`
	Adjustments   map[uint64][]byte `protobuf:"bytes,4,rep,name=adjustments,proto3" json:"adjustments,omitempty" protobuf_key:"varint,1,opt,name=key,proto3" protobuf_val:"bytes,2,opt,name=value,proto3"`
	AntiReplay    bool              `protobuf:"varint,5,opt,name=anti_replay,json=antiReplay,proto3" json:"anti_replay,omitempty"`
}

func (x *AssetFlow) Reset() {
	*x = AssetFlow{}
	if protoimpl.UnsafeEnabled {
		mi := &file_policy_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *AssetFlow) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*AssetFlow) ProtoMessage() {}

func (x *AssetFlow) ProtoReflect() protoreflect.Message {
	mi := &file_policy_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use AssetFlow.ProtoReflect.Descriptor instead.
func (*AssetFlow) Descriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{1}
}

func (x *AssetFlow) GetAddressPrefix() string {
	if x != nil {
		return x.AddressPrefix
	}
	return ""
}

func (x *AssetFlow) GetCookedAddress() string {
	if x != nil {
		return x.CookedAddress
	}
	return ""
}

func (x *AssetFlow) GetRawAddress() []byte {
	if x != nil {
		return x.RawAddress
	}
	return nil
}

func (x *AssetFlow) GetAdjustments() map[uint64][]byte {
	if x != nil {
		return x.Adjustments
	}
	return nil
}

func (x *AssetFlow) GetAntiReplay() bool {
	if x != nil {
		return x.AntiReplay
	}
	return false
}

type Transaction struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Tag    TransactionTag `protobuf:"varint,1,opt,name=tag,proto3,enum=com.qredo.blackbird.TransactionTag" json:"tag,omitempty"`
	Assets []*Asset       `protobuf:"bytes,2,rep,name=assets,proto3" json:"assets,omitempty"`
	Flows  []*AssetFlow   `protobuf:"bytes,3,rep,name=flows,proto3" json:"flows,omitempty"`
	Focus  uint64         `protobuf:"varint,4,opt,name=focus,proto3" json:"focus,omitempty"`
}

func (x *Transaction) Reset() {
	*x = Transaction{}
	if protoimpl.UnsafeEnabled {
		mi := &file_policy_proto_msgTypes[2]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Transaction) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Transaction) ProtoMessage() {}

func (x *Transaction) ProtoReflect() protoreflect.Message {
	mi := &file_policy_proto_msgTypes[2]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Transaction.ProtoReflect.Descriptor instead.
func (*Transaction) Descriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{2}
}

func (x *Transaction) GetTag() TransactionTag {
	if x != nil {
		return x.Tag
	}
	return TransactionTag_TRANSACTION_UNSPECIFIED
}

func (x *Transaction) GetAssets() []*Asset {
	if x != nil {
		return x.Assets
	}
	return nil
}

func (x *Transaction) GetFlows() []*AssetFlow {
	if x != nil {
		return x.Flows
	}
	return nil
}

func (x *Transaction) GetFocus() uint64 {
	if x != nil {
		return x.Focus
	}
	return 0
}

type Policy struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Tag           PolicyTag `protobuf:"varint,1,opt,name=tag,proto3,enum=com.qredo.blackbird.PolicyTag" json:"tag,omitempty"`
	Threshold     uint64    `protobuf:"varint,2,opt,name=threshold,proto3" json:"threshold,omitempty"`
	Subpolicies   []*Policy `protobuf:"bytes,3,rep,name=subpolicies,proto3" json:"subpolicies,omitempty"`
	AddressPrefix string    `protobuf:"bytes,16,opt,name=address_prefix,json=addressPrefix,proto3" json:"address_prefix,omitempty"`
	// Types that are assignable to Address:
	//
	//	*Policy_CookedAddress
	//	*Policy_RawAddress
	Address     isPolicy_Address  `protobuf_oneof:"address"`
	Assets      map[uint64][]byte `protobuf:"bytes,6,rep,name=assets,proto3" json:"assets,omitempty" protobuf_key:"varint,1,opt,name=key,proto3" protobuf_val:"bytes,2,opt,name=value,proto3"`
	AssetDefs   []*Asset          `protobuf:"bytes,7,rep,name=asset_defs,json=assetDefs,proto3" json:"asset_defs,omitempty"`
	Thunk       []byte            `protobuf:"bytes,8,opt,name=thunk,proto3" json:"thunk,omitempty"`
	RefId       uint64            `protobuf:"varint,9,opt,name=ref_id,json=refId,proto3" json:"ref_id,omitempty"`
	Transaction *Transaction      `protobuf:"bytes,17,opt,name=transaction,proto3" json:"transaction,omitempty"`
}

func (x *Policy) Reset() {
	*x = Policy{}
	if protoimpl.UnsafeEnabled {
		mi := &file_policy_proto_msgTypes[3]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Policy) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Policy) ProtoMessage() {}

func (x *Policy) ProtoReflect() protoreflect.Message {
	mi := &file_policy_proto_msgTypes[3]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Policy.ProtoReflect.Descriptor instead.
func (*Policy) Descriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{3}
}

func (x *Policy) GetTag() PolicyTag {
	if x != nil {
		return x.Tag
	}
	return PolicyTag_POLICY_UNSPECIFIED
}

func (x *Policy) GetThreshold() uint64 {
	if x != nil {
		return x.Threshold
	}
	return 0
}

func (x *Policy) GetSubpolicies() []*Policy {
	if x != nil {
		return x.Subpolicies
	}
	return nil
}

func (x *Policy) GetAddressPrefix() string {
	if x != nil {
		return x.AddressPrefix
	}
	return ""
}

func (m *Policy) GetAddress() isPolicy_Address {
	if m != nil {
		return m.Address
	}
	return nil
}

func (x *Policy) GetCookedAddress() string {
	if x, ok := x.GetAddress().(*Policy_CookedAddress); ok {
		return x.CookedAddress
	}
	return ""
}

func (x *Policy) GetRawAddress() []byte {
	if x, ok := x.GetAddress().(*Policy_RawAddress); ok {
		return x.RawAddress
	}
	return nil
}

func (x *Policy) GetAssets() map[uint64][]byte {
	if x != nil {
		return x.Assets
	}
	return nil
}

func (x *Policy) GetAssetDefs() []*Asset {
	if x != nil {
		return x.AssetDefs
	}
	return nil
}

func (x *Policy) GetThunk() []byte {
	if x != nil {
		return x.Thunk
	}
	return nil
}

func (x *Policy) GetRefId() uint64 {
	if x != nil {
		return x.RefId
	}
	return 0
}

func (x *Policy) GetTransaction() *Transaction {
	if x != nil {
		return x.Transaction
	}
	return nil
}

type isPolicy_Address interface {
	isPolicy_Address()
}

type Policy_CookedAddress struct {
	CookedAddress string `protobuf:"bytes,4,opt,name=cooked_address,json=cookedAddress,proto3,oneof"`
}

type Policy_RawAddress struct {
	RawAddress []byte `protobuf:"bytes,5,opt,name=raw_address,json=rawAddress,proto3,oneof"`
}

func (*Policy_CookedAddress) isPolicy_Address() {}

func (*Policy_RawAddress) isPolicy_Address() {}

type Witness struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Tag          WitnessTag          `protobuf:"varint,1,opt,name=tag,proto3,enum=com.qredo.blackbird.WitnessTag" json:"tag,omitempty"`
	AllWitnesses []*Witness          `protobuf:"bytes,2,rep,name=all_witnesses,json=allWitnesses,proto3" json:"all_witnesses,omitempty"`
	AnyWitnesses map[uint64]*Witness `protobuf:"bytes,3,rep,name=any_witnesses,json=anyWitnesses,proto3" json:"any_witnesses,omitempty" protobuf_key:"varint,1,opt,name=key,proto3" protobuf_val:"bytes,2,opt,name=value,proto3"`
	NextWitness  *Witness            `protobuf:"bytes,4,opt,name=next_witness,json=nextWitness,proto3" json:"next_witness,omitempty"`
}

func (x *Witness) Reset() {
	*x = Witness{}
	if protoimpl.UnsafeEnabled {
		mi := &file_policy_proto_msgTypes[4]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Witness) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Witness) ProtoMessage() {}

func (x *Witness) ProtoReflect() protoreflect.Message {
	mi := &file_policy_proto_msgTypes[4]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Witness.ProtoReflect.Descriptor instead.
func (*Witness) Descriptor() ([]byte, []int) {
	return file_policy_proto_rawDescGZIP(), []int{4}
}

func (x *Witness) GetTag() WitnessTag {
	if x != nil {
		return x.Tag
	}
	return WitnessTag_WITNESS_UNSPECIFIED
}

func (x *Witness) GetAllWitnesses() []*Witness {
	if x != nil {
		return x.AllWitnesses
	}
	return nil
}

func (x *Witness) GetAnyWitnesses() map[uint64]*Witness {
	if x != nil {
		return x.AnyWitnesses
	}
	return nil
}

func (x *Witness) GetNextWitness() *Witness {
	if x != nil {
		return x.NextWitness
	}
	return nil
}

var File_policy_proto protoreflect.FileDescriptor

var file_policy_proto_rawDesc = []byte{
	0x0a, 0x0c, 0x70, 0x6f, 0x6c, 0x69, 0x63, 0x79, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x12, 0x13,
	0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62,
	0x69, 0x72, 0x64, 0x22, 0xbf, 0x01, 0x0a, 0x05, 0x41, 0x73, 0x73, 0x65, 0x74, 0x12, 0x37, 0x0a,
	0x03, 0x74, 0x61, 0x67, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0e, 0x32, 0x25, 0x2e, 0x63, 0x6f, 0x6d,
	0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64,
	0x2e, 0x41, 0x73, 0x73, 0x65, 0x74, 0x50, 0x72, 0x6f, 0x74, 0x6f, 0x63, 0x6f, 0x6c, 0x54, 0x61,
	0x67, 0x52, 0x03, 0x74, 0x61, 0x67, 0x12, 0x19, 0x0a, 0x08, 0x63, 0x68, 0x61, 0x69, 0x6e, 0x5f,
	0x69, 0x64, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x07, 0x63, 0x68, 0x61, 0x69, 0x6e, 0x49,
	0x64, 0x12, 0x25, 0x0a, 0x0e, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x5f, 0x70, 0x72, 0x65,
	0x66, 0x69, 0x78, 0x18, 0x03, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0d, 0x61, 0x64, 0x64, 0x72, 0x65,
	0x73, 0x73, 0x50, 0x72, 0x65, 0x66, 0x69, 0x78, 0x12, 0x1f, 0x0a, 0x0b, 0x72, 0x61, 0x77, 0x5f,
	0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x18, 0x05, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x0a, 0x72,
	0x61, 0x77, 0x41, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x12, 0x1a, 0x0a, 0x08, 0x73, 0x65, 0x6c,
	0x65, 0x63, 0x74, 0x6f, 0x72, 0x18, 0x06, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x08, 0x73, 0x65, 0x6c,
	0x65, 0x63, 0x74, 0x6f, 0x72, 0x22, 0xae, 0x02, 0x0a, 0x09, 0x41, 0x73, 0x73, 0x65, 0x74, 0x46,
	0x6c, 0x6f, 0x77, 0x12, 0x25, 0x0a, 0x0e, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x5f, 0x70,
	0x72, 0x65, 0x66, 0x69, 0x78, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0d, 0x61, 0x64, 0x64,
	0x72, 0x65, 0x73, 0x73, 0x50, 0x72, 0x65, 0x66, 0x69, 0x78, 0x12, 0x25, 0x0a, 0x0e, 0x63, 0x6f,
	0x6f, 0x6b, 0x65, 0x64, 0x5f, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x18, 0x02, 0x20, 0x01,
	0x28, 0x09, 0x52, 0x0d, 0x63, 0x6f, 0x6f, 0x6b, 0x65, 0x64, 0x41, 0x64, 0x64, 0x72, 0x65, 0x73,
	0x73, 0x12, 0x1f, 0x0a, 0x0b, 0x72, 0x61, 0x77, 0x5f, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73,
	0x18, 0x03, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x0a, 0x72, 0x61, 0x77, 0x41, 0x64, 0x64, 0x72, 0x65,
	0x73, 0x73, 0x12, 0x51, 0x0a, 0x0b, 0x61, 0x64, 0x6a, 0x75, 0x73, 0x74, 0x6d, 0x65, 0x6e, 0x74,
	0x73, 0x18, 0x04, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x2f, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72,
	0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x41, 0x73,
	0x73, 0x65, 0x74, 0x46, 0x6c, 0x6f, 0x77, 0x2e, 0x41, 0x64, 0x6a, 0x75, 0x73, 0x74, 0x6d, 0x65,
	0x6e, 0x74, 0x73, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x52, 0x0b, 0x61, 0x64, 0x6a, 0x75, 0x73, 0x74,
	0x6d, 0x65, 0x6e, 0x74, 0x73, 0x12, 0x1f, 0x0a, 0x0b, 0x61, 0x6e, 0x74, 0x69, 0x5f, 0x72, 0x65,
	0x70, 0x6c, 0x61, 0x79, 0x18, 0x05, 0x20, 0x01, 0x28, 0x08, 0x52, 0x0a, 0x61, 0x6e, 0x74, 0x69,
	0x52, 0x65, 0x70, 0x6c, 0x61, 0x79, 0x1a, 0x3e, 0x0a, 0x10, 0x41, 0x64, 0x6a, 0x75, 0x73, 0x74,
	0x6d, 0x65, 0x6e, 0x74, 0x73, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x12, 0x10, 0x0a, 0x03, 0x6b, 0x65,
	0x79, 0x18, 0x01, 0x20, 0x01, 0x28, 0x04, 0x52, 0x03, 0x6b, 0x65, 0x79, 0x12, 0x14, 0x0a, 0x05,
	0x76, 0x61, 0x6c, 0x75, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x05, 0x76, 0x61, 0x6c,
	0x75, 0x65, 0x3a, 0x02, 0x38, 0x01, 0x22, 0xc4, 0x01, 0x0a, 0x0b, 0x54, 0x72, 0x61, 0x6e, 0x73,
	0x61, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x12, 0x35, 0x0a, 0x03, 0x74, 0x61, 0x67, 0x18, 0x01, 0x20,
	0x01, 0x28, 0x0e, 0x32, 0x23, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e,
	0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x54, 0x72, 0x61, 0x6e, 0x73, 0x61,
	0x63, 0x74, 0x69, 0x6f, 0x6e, 0x54, 0x61, 0x67, 0x52, 0x03, 0x74, 0x61, 0x67, 0x12, 0x32, 0x0a,
	0x06, 0x61, 0x73, 0x73, 0x65, 0x74, 0x73, 0x18, 0x02, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x1a, 0x2e,
	0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62,
	0x69, 0x72, 0x64, 0x2e, 0x41, 0x73, 0x73, 0x65, 0x74, 0x52, 0x06, 0x61, 0x73, 0x73, 0x65, 0x74,
	0x73, 0x12, 0x34, 0x0a, 0x05, 0x66, 0x6c, 0x6f, 0x77, 0x73, 0x18, 0x03, 0x20, 0x03, 0x28, 0x0b,
	0x32, 0x1e, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61,
	0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x41, 0x73, 0x73, 0x65, 0x74, 0x46, 0x6c, 0x6f, 0x77,
	0x52, 0x05, 0x66, 0x6c, 0x6f, 0x77, 0x73, 0x12, 0x14, 0x0a, 0x05, 0x66, 0x6f, 0x63, 0x75, 0x73,
	0x18, 0x04, 0x20, 0x01, 0x28, 0x04, 0x52, 0x05, 0x66, 0x6f, 0x63, 0x75, 0x73, 0x22, 0xbd, 0x04,
	0x0a, 0x06, 0x50, 0x6f, 0x6c, 0x69, 0x63, 0x79, 0x12, 0x30, 0x0a, 0x03, 0x74, 0x61, 0x67, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x0e, 0x32, 0x1e, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64,
	0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x50, 0x6f, 0x6c, 0x69,
	0x63, 0x79, 0x54, 0x61, 0x67, 0x52, 0x03, 0x74, 0x61, 0x67, 0x12, 0x1c, 0x0a, 0x09, 0x74, 0x68,
	0x72, 0x65, 0x73, 0x68, 0x6f, 0x6c, 0x64, 0x18, 0x02, 0x20, 0x01, 0x28, 0x04, 0x52, 0x09, 0x74,
	0x68, 0x72, 0x65, 0x73, 0x68, 0x6f, 0x6c, 0x64, 0x12, 0x3d, 0x0a, 0x0b, 0x73, 0x75, 0x62, 0x70,
	0x6f, 0x6c, 0x69, 0x63, 0x69, 0x65, 0x73, 0x18, 0x03, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x1b, 0x2e,
	0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62,
	0x69, 0x72, 0x64, 0x2e, 0x50, 0x6f, 0x6c, 0x69, 0x63, 0x79, 0x52, 0x0b, 0x73, 0x75, 0x62, 0x70,
	0x6f, 0x6c, 0x69, 0x63, 0x69, 0x65, 0x73, 0x12, 0x25, 0x0a, 0x0e, 0x61, 0x64, 0x64, 0x72, 0x65,
	0x73, 0x73, 0x5f, 0x70, 0x72, 0x65, 0x66, 0x69, 0x78, 0x18, 0x10, 0x20, 0x01, 0x28, 0x09, 0x52,
	0x0d, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x50, 0x72, 0x65, 0x66, 0x69, 0x78, 0x12, 0x27,
	0x0a, 0x0e, 0x63, 0x6f, 0x6f, 0x6b, 0x65, 0x64, 0x5f, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73,
	0x18, 0x04, 0x20, 0x01, 0x28, 0x09, 0x48, 0x00, 0x52, 0x0d, 0x63, 0x6f, 0x6f, 0x6b, 0x65, 0x64,
	0x41, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x12, 0x21, 0x0a, 0x0b, 0x72, 0x61, 0x77, 0x5f, 0x61,
	0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x18, 0x05, 0x20, 0x01, 0x28, 0x0c, 0x48, 0x00, 0x52, 0x0a,
	0x72, 0x61, 0x77, 0x41, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x12, 0x3f, 0x0a, 0x06, 0x61, 0x73,
	0x73, 0x65, 0x74, 0x73, 0x18, 0x06, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x27, 0x2e, 0x63, 0x6f, 0x6d,
	0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64,
	0x2e, 0x50, 0x6f, 0x6c, 0x69, 0x63, 0x79, 0x2e, 0x41, 0x73, 0x73, 0x65, 0x74, 0x73, 0x45, 0x6e,
	0x74, 0x72, 0x79, 0x52, 0x06, 0x61, 0x73, 0x73, 0x65, 0x74, 0x73, 0x12, 0x39, 0x0a, 0x0a, 0x61,
	0x73, 0x73, 0x65, 0x74, 0x5f, 0x64, 0x65, 0x66, 0x73, 0x18, 0x07, 0x20, 0x03, 0x28, 0x0b, 0x32,
	0x1a, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63,
	0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x41, 0x73, 0x73, 0x65, 0x74, 0x52, 0x09, 0x61, 0x73, 0x73,
	0x65, 0x74, 0x44, 0x65, 0x66, 0x73, 0x12, 0x14, 0x0a, 0x05, 0x74, 0x68, 0x75, 0x6e, 0x6b, 0x18,
	0x08, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x05, 0x74, 0x68, 0x75, 0x6e, 0x6b, 0x12, 0x15, 0x0a, 0x06,
	0x72, 0x65, 0x66, 0x5f, 0x69, 0x64, 0x18, 0x09, 0x20, 0x01, 0x28, 0x04, 0x52, 0x05, 0x72, 0x65,
	0x66, 0x49, 0x64, 0x12, 0x42, 0x0a, 0x0b, 0x74, 0x72, 0x61, 0x6e, 0x73, 0x61, 0x63, 0x74, 0x69,
	0x6f, 0x6e, 0x18, 0x11, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x20, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71,
	0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x54,
	0x72, 0x61, 0x6e, 0x73, 0x61, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x52, 0x0b, 0x74, 0x72, 0x61, 0x6e,
	0x73, 0x61, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x1a, 0x39, 0x0a, 0x0b, 0x41, 0x73, 0x73, 0x65, 0x74,
	0x73, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x12, 0x10, 0x0a, 0x03, 0x6b, 0x65, 0x79, 0x18, 0x01, 0x20,
	0x01, 0x28, 0x04, 0x52, 0x03, 0x6b, 0x65, 0x79, 0x12, 0x14, 0x0a, 0x05, 0x76, 0x61, 0x6c, 0x75,
	0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x05, 0x76, 0x61, 0x6c, 0x75, 0x65, 0x3a, 0x02,
	0x38, 0x01, 0x42, 0x09, 0x0a, 0x07, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, 0x22, 0xf4, 0x02,
	0x0a, 0x07, 0x57, 0x69, 0x74, 0x6e, 0x65, 0x73, 0x73, 0x12, 0x31, 0x0a, 0x03, 0x74, 0x61, 0x67,
	0x18, 0x01, 0x20, 0x01, 0x28, 0x0e, 0x32, 0x1f, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65,
	0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x57, 0x69, 0x74,
	0x6e, 0x65, 0x73, 0x73, 0x54, 0x61, 0x67, 0x52, 0x03, 0x74, 0x61, 0x67, 0x12, 0x41, 0x0a, 0x0d,
	0x61, 0x6c, 0x6c, 0x5f, 0x77, 0x69, 0x74, 0x6e, 0x65, 0x73, 0x73, 0x65, 0x73, 0x18, 0x02, 0x20,
	0x03, 0x28, 0x0b, 0x32, 0x1c, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e,
	0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x57, 0x69, 0x74, 0x6e, 0x65, 0x73,
	0x73, 0x52, 0x0c, 0x61, 0x6c, 0x6c, 0x57, 0x69, 0x74, 0x6e, 0x65, 0x73, 0x73, 0x65, 0x73, 0x12,
	0x53, 0x0a, 0x0d, 0x61, 0x6e, 0x79, 0x5f, 0x77, 0x69, 0x74, 0x6e, 0x65, 0x73, 0x73, 0x65, 0x73,
	0x18, 0x03, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x2e, 0x2e, 0x63, 0x6f, 0x6d, 0x2e, 0x71, 0x72, 0x65,
	0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64, 0x2e, 0x57, 0x69, 0x74,
	0x6e, 0x65, 0x73, 0x73, 0x2e, 0x41, 0x6e, 0x79, 0x57, 0x69, 0x74, 0x6e, 0x65, 0x73, 0x73, 0x65,
	0x73, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x52, 0x0c, 0x61, 0x6e, 0x79, 0x57, 0x69, 0x74, 0x6e, 0x65,
	0x73, 0x73, 0x65, 0x73, 0x12, 0x3f, 0x0a, 0x0c, 0x6e, 0x65, 0x78, 0x74, 0x5f, 0x77, 0x69, 0x74,
	0x6e, 0x65, 0x73, 0x73, 0x18, 0x04, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1c, 0x2e, 0x63, 0x6f, 0x6d,
	0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72, 0x64,
	0x2e, 0x57, 0x69, 0x74, 0x6e, 0x65, 0x73, 0x73, 0x52, 0x0b, 0x6e, 0x65, 0x78, 0x74, 0x57, 0x69,
	0x74, 0x6e, 0x65, 0x73, 0x73, 0x1a, 0x5d, 0x0a, 0x11, 0x41, 0x6e, 0x79, 0x57, 0x69, 0x74, 0x6e,
	0x65, 0x73, 0x73, 0x65, 0x73, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x12, 0x10, 0x0a, 0x03, 0x6b, 0x65,
	0x79, 0x18, 0x01, 0x20, 0x01, 0x28, 0x04, 0x52, 0x03, 0x6b, 0x65, 0x79, 0x12, 0x32, 0x0a, 0x05,
	0x76, 0x61, 0x6c, 0x75, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1c, 0x2e, 0x63, 0x6f,
	0x6d, 0x2e, 0x71, 0x72, 0x65, 0x64, 0x6f, 0x2e, 0x62, 0x6c, 0x61, 0x63, 0x6b, 0x62, 0x69, 0x72,
	0x64, 0x2e, 0x57, 0x69, 0x74, 0x6e, 0x65, 0x73, 0x73, 0x52, 0x05, 0x76, 0x61, 0x6c, 0x75, 0x65,
	0x3a, 0x02, 0x38, 0x01, 0x2a, 0x97, 0x01, 0x0a, 0x10, 0x41, 0x73, 0x73, 0x65, 0x74, 0x50, 0x72,
	0x6f, 0x74, 0x6f, 0x63, 0x6f, 0x6c, 0x54, 0x61, 0x67, 0x12, 0x1e, 0x0a, 0x1a, 0x41, 0x53, 0x53,
	0x45, 0x54, 0x5f, 0x50, 0x52, 0x4f, 0x54, 0x4f, 0x43, 0x4f, 0x4c, 0x5f, 0x55, 0x4e, 0x53, 0x50,
	0x45, 0x43, 0x49, 0x46, 0x49, 0x45, 0x44, 0x10, 0x00, 0x12, 0x16, 0x0a, 0x12, 0x41, 0x53, 0x53,
	0x45, 0x54, 0x5f, 0x50, 0x52, 0x4f, 0x54, 0x4f, 0x43, 0x4f, 0x4c, 0x5f, 0x42, 0x54, 0x43, 0x10,
	0x01, 0x12, 0x16, 0x0a, 0x12, 0x41, 0x53, 0x53, 0x45, 0x54, 0x5f, 0x50, 0x52, 0x4f, 0x54, 0x4f,
	0x43, 0x4f, 0x4c, 0x5f, 0x45, 0x56, 0x4d, 0x10, 0x02, 0x12, 0x18, 0x0a, 0x14, 0x41, 0x53, 0x53,
	0x45, 0x54, 0x5f, 0x50, 0x52, 0x4f, 0x54, 0x4f, 0x43, 0x4f, 0x4c, 0x5f, 0x45, 0x52, 0x43, 0x32,
	0x30, 0x10, 0x03, 0x12, 0x19, 0x0a, 0x15, 0x41, 0x53, 0x53, 0x45, 0x54, 0x5f, 0x50, 0x52, 0x4f,
	0x54, 0x4f, 0x43, 0x4f, 0x4c, 0x5f, 0x43, 0x4f, 0x53, 0x4d, 0x4f, 0x53, 0x10, 0x04, 0x2a, 0x48,
	0x0a, 0x0e, 0x54, 0x72, 0x61, 0x6e, 0x73, 0x61, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x54, 0x61, 0x67,
	0x12, 0x1b, 0x0a, 0x17, 0x54, 0x52, 0x41, 0x4e, 0x53, 0x41, 0x43, 0x54, 0x49, 0x4f, 0x4e, 0x5f,
	0x55, 0x4e, 0x53, 0x50, 0x45, 0x43, 0x49, 0x46, 0x49, 0x45, 0x44, 0x10, 0x00, 0x12, 0x19, 0x0a,
	0x15, 0x54, 0x52, 0x41, 0x4e, 0x53, 0x41, 0x43, 0x54, 0x49, 0x4f, 0x4e, 0x5f, 0x49, 0x4d, 0x4d,
	0x45, 0x44, 0x49, 0x41, 0x54, 0x45, 0x10, 0x01, 0x2a, 0xfe, 0x01, 0x0a, 0x09, 0x50, 0x6f, 0x6c,
	0x69, 0x63, 0x79, 0x54, 0x61, 0x67, 0x12, 0x16, 0x0a, 0x12, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59,
	0x5f, 0x55, 0x4e, 0x53, 0x50, 0x45, 0x43, 0x49, 0x46, 0x49, 0x45, 0x44, 0x10, 0x00, 0x12, 0x0e,
	0x0a, 0x0a, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x41, 0x4c, 0x4c, 0x10, 0x01, 0x12, 0x0e,
	0x0a, 0x0a, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x41, 0x4e, 0x59, 0x10, 0x02, 0x12, 0x14,
	0x0a, 0x10, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x53, 0x49, 0x47, 0x4e, 0x41, 0x54, 0x55,
	0x52, 0x45, 0x10, 0x03, 0x12, 0x14, 0x0a, 0x10, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x52,
	0x45, 0x46, 0x5f, 0x4c, 0x4f, 0x43, 0x41, 0x4c, 0x10, 0x04, 0x12, 0x11, 0x0a, 0x0d, 0x50, 0x4f,
	0x4c, 0x49, 0x43, 0x59, 0x5f, 0x41, 0x53, 0x53, 0x45, 0x54, 0x53, 0x10, 0x05, 0x12, 0x0f, 0x0a,
	0x0b, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x4c, 0x49, 0x53, 0x54, 0x10, 0x06, 0x12, 0x12,
	0x0a, 0x0e, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x43, 0x4c, 0x4f, 0x53, 0x55, 0x52, 0x45,
	0x10, 0x07, 0x12, 0x10, 0x0a, 0x0c, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x54, 0x41, 0x42,
	0x4c, 0x45, 0x10, 0x10, 0x12, 0x16, 0x0a, 0x12, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x54,
	0x52, 0x41, 0x4e, 0x53, 0x41, 0x43, 0x54, 0x49, 0x4f, 0x4e, 0x10, 0x11, 0x12, 0x15, 0x0a, 0x11,
	0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x41, 0x53, 0x53, 0x45, 0x54, 0x5f, 0x46, 0x4c, 0x4f,
	0x57, 0x10, 0x12, 0x12, 0x14, 0x0a, 0x0f, 0x50, 0x4f, 0x4c, 0x49, 0x43, 0x59, 0x5f, 0x52, 0x45,
	0x46, 0x5f, 0x54, 0x45, 0x4d, 0x50, 0x10, 0xff, 0x01, 0x2a, 0xb2, 0x01, 0x0a, 0x0a, 0x57, 0x69,
	0x74, 0x6e, 0x65, 0x73, 0x73, 0x54, 0x61, 0x67, 0x12, 0x17, 0x0a, 0x13, 0x57, 0x49, 0x54, 0x4e,
	0x45, 0x53, 0x53, 0x5f, 0x55, 0x4e, 0x53, 0x50, 0x45, 0x43, 0x49, 0x46, 0x49, 0x45, 0x44, 0x10,
	0x00, 0x12, 0x11, 0x0a, 0x0d, 0x57, 0x49, 0x54, 0x4e, 0x45, 0x53, 0x53, 0x5f, 0x47, 0x55, 0x45,
	0x53, 0x53, 0x10, 0x01, 0x12, 0x0f, 0x0a, 0x0b, 0x57, 0x49, 0x54, 0x4e, 0x45, 0x53, 0x53, 0x5f,
	0x41, 0x4c, 0x4c, 0x10, 0x02, 0x12, 0x0f, 0x0a, 0x0b, 0x57, 0x49, 0x54, 0x4e, 0x45, 0x53, 0x53,
	0x5f, 0x41, 0x4e, 0x59, 0x10, 0x03, 0x12, 0x20, 0x0a, 0x1c, 0x57, 0x49, 0x54, 0x4e, 0x45, 0x53,
	0x53, 0x5f, 0x50, 0x52, 0x45, 0x43, 0x48, 0x45, 0x43, 0x4b, 0x45, 0x44, 0x5f, 0x53, 0x49, 0x47,
	0x4e, 0x41, 0x54, 0x55, 0x52, 0x45, 0x10, 0x04, 0x12, 0x11, 0x0a, 0x0d, 0x57, 0x49, 0x54, 0x4e,
	0x45, 0x53, 0x53, 0x5f, 0x54, 0x41, 0x42, 0x4c, 0x45, 0x10, 0x05, 0x12, 0x10, 0x0a, 0x0c, 0x57,
	0x49, 0x54, 0x4e, 0x45, 0x53, 0x53, 0x5f, 0x45, 0x56, 0x41, 0x4c, 0x10, 0x06, 0x12, 0x0f, 0x0a,
	0x0b, 0x57, 0x49, 0x54, 0x4e, 0x45, 0x53, 0x53, 0x5f, 0x52, 0x45, 0x46, 0x10, 0x07, 0x62, 0x06,
	0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_policy_proto_rawDescOnce sync.Once
	file_policy_proto_rawDescData = file_policy_proto_rawDesc
)

func file_policy_proto_rawDescGZIP() []byte {
	file_policy_proto_rawDescOnce.Do(func() {
		file_policy_proto_rawDescData = protoimpl.X.CompressGZIP(file_policy_proto_rawDescData)
	})
	return file_policy_proto_rawDescData
}

var file_policy_proto_enumTypes = make([]protoimpl.EnumInfo, 4)
var file_policy_proto_msgTypes = make([]protoimpl.MessageInfo, 8)
var file_policy_proto_goTypes = []interface{}{
	(AssetProtocolTag)(0), // 0: com.qredo.blackbird.AssetProtocolTag
	(TransactionTag)(0),   // 1: com.qredo.blackbird.TransactionTag
	(PolicyTag)(0),        // 2: com.qredo.blackbird.PolicyTag
	(WitnessTag)(0),       // 3: com.qredo.blackbird.WitnessTag
	(*Asset)(nil),         // 4: com.qredo.blackbird.Asset
	(*AssetFlow)(nil),     // 5: com.qredo.blackbird.AssetFlow
	(*Transaction)(nil),   // 6: com.qredo.blackbird.Transaction
	(*Policy)(nil),        // 7: com.qredo.blackbird.Policy
	(*Witness)(nil),       // 8: com.qredo.blackbird.Witness
	nil,                   // 9: com.qredo.blackbird.AssetFlow.AdjustmentsEntry
	nil,                   // 10: com.qredo.blackbird.Policy.AssetsEntry
	nil,                   // 11: com.qredo.blackbird.Witness.AnyWitnessesEntry
}
var file_policy_proto_depIdxs = []int32{
	0,  // 0: com.qredo.blackbird.Asset.tag:type_name -> com.qredo.blackbird.AssetProtocolTag
	9,  // 1: com.qredo.blackbird.AssetFlow.adjustments:type_name -> com.qredo.blackbird.AssetFlow.AdjustmentsEntry
	1,  // 2: com.qredo.blackbird.Transaction.tag:type_name -> com.qredo.blackbird.TransactionTag
	4,  // 3: com.qredo.blackbird.Transaction.assets:type_name -> com.qredo.blackbird.Asset
	5,  // 4: com.qredo.blackbird.Transaction.flows:type_name -> com.qredo.blackbird.AssetFlow
	2,  // 5: com.qredo.blackbird.Policy.tag:type_name -> com.qredo.blackbird.PolicyTag
	7,  // 6: com.qredo.blackbird.Policy.subpolicies:type_name -> com.qredo.blackbird.Policy
	10, // 7: com.qredo.blackbird.Policy.assets:type_name -> com.qredo.blackbird.Policy.AssetsEntry
	4,  // 8: com.qredo.blackbird.Policy.asset_defs:type_name -> com.qredo.blackbird.Asset
	6,  // 9: com.qredo.blackbird.Policy.transaction:type_name -> com.qredo.blackbird.Transaction
	3,  // 10: com.qredo.blackbird.Witness.tag:type_name -> com.qredo.blackbird.WitnessTag
	8,  // 11: com.qredo.blackbird.Witness.all_witnesses:type_name -> com.qredo.blackbird.Witness
	11, // 12: com.qredo.blackbird.Witness.any_witnesses:type_name -> com.qredo.blackbird.Witness.AnyWitnessesEntry
	8,  // 13: com.qredo.blackbird.Witness.next_witness:type_name -> com.qredo.blackbird.Witness
	8,  // 14: com.qredo.blackbird.Witness.AnyWitnessesEntry.value:type_name -> com.qredo.blackbird.Witness
	15, // [15:15] is the sub-list for method output_type
	15, // [15:15] is the sub-list for method input_type
	15, // [15:15] is the sub-list for extension type_name
	15, // [15:15] is the sub-list for extension extendee
	0,  // [0:15] is the sub-list for field type_name
}

func init() { file_policy_proto_init() }
func file_policy_proto_init() {
	if File_policy_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_policy_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Asset); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_policy_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*AssetFlow); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_policy_proto_msgTypes[2].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Transaction); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_policy_proto_msgTypes[3].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Policy); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_policy_proto_msgTypes[4].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Witness); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	file_policy_proto_msgTypes[3].OneofWrappers = []interface{}{
		(*Policy_CookedAddress)(nil),
		(*Policy_RawAddress)(nil),
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_policy_proto_rawDesc,
			NumEnums:      4,
			NumMessages:   8,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_policy_proto_goTypes,
		DependencyIndexes: file_policy_proto_depIdxs,
		EnumInfos:         file_policy_proto_enumTypes,
		MessageInfos:      file_policy_proto_msgTypes,
	}.Build()
	File_policy_proto = out.File
	file_policy_proto_rawDesc = nil
	file_policy_proto_goTypes = nil
	file_policy_proto_depIdxs = nil
}